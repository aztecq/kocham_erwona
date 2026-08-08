class_name ScoreCard extends Node

# The dig's ledger. Everything worth finding on the map is priced at generation time —
# that sum is the bar's far end — and from then on this only watches: terrain and
# artifact signals tell it what came to light and what got wrecked. Nothing calls into
# it, so no tool or controller can forget to keep the score.

signal changed

const FLOOR_TILE_POINTS := 2
const WALL_TILE_POINTS := 3
# What one mark on the stonework costs — a tool swung at a wall it can't work. Cheap next
# to losing the stone outright, and charged once per stone, so scraping a blade along a
# whole wall stings without ruining the dig.
const SCUFF_POINTS := 1
# What a wrecked tile costs on top of never getting to discover it. Damage hurts more
# than ignorance, so smashing through a ruin is worse than walking away from one.
const DAMAGE_MULTIPLIER := 2

# The full value of the site, fixed at bind. Progress is discovered against this.
var total := 0
var discovered := 0
var damaged := 0

var _terrain: TerrainData

# One entry per world cell a ruin occupies — the cell's whole stack of stonework, since
# a top-down dig can only ever see the top of it. Keyed by cell:
#   top: level of the highest stone, which is what has to surface for the find to count
#   levels: {level: points} per stone still standing
#   points: the column's worth, paid out once on discovery
#   discovered: whether it's been paid
#   scuffed: {level: true} for stones already marked, so a mark is charged only once
var _columns := {}

func bind(terrain: TerrainData, artifacts: ArtifactData, controller: TerrainController) -> void:
	_terrain = terrain
	for placed in terrain.structures:
		_price_structure(placed)
	for artifact in artifacts.artifacts:
		total += artifact.value

	# Ruins can breach the surface at generation: those columns start discovered.
	for cell in _columns:
		_check_discovery(cell)

	terrain.tile_changed.connect(_on_tile_changed)
	artifacts.artifact_taken.connect(_on_artifact_taken)
	artifacts.artifact_degraded.connect(_on_artifact_degraded)
	controller.stone_struck.connect(_on_stone_struck)
	changed.emit()

func fraction() -> float:
	return float(discovered) / total if total > 0 else 0.0

# What the level pays when the player calls it done. Damage is charged at a premium, so
# a careless dig can be worth less than a shallow one.
func payout() -> int:
	return maxi(0, discovered - damaged * DAMAGE_MULTIPLIER)

func _price_structure(placed: TerrainData.PlacedStructure) -> void:
	var structure := placed.structure
	var base := TerrainLayers.STRUCTURE_FLOOR_LEVEL
	for y in structure.size.y:
		for x in structure.size.x:
			var local := Vector2i(x, y)
			var levels := {}
			if structure.is_floor(local):
				levels[base] = FLOOR_TILE_POINTS
			for level in TerrainLayers.wall_levels():
				if structure.is_wall(level, local):
					levels[base + 1 + level] = WALL_TILE_POINTS
			if levels.is_empty():
				continue
			var points := 0
			for level in levels:
				points += levels[level]
			total += points
			_columns[placed.origin + local] = {
				top = levels.keys().max(),
				levels = levels,
				points = points,
				discovered = false,
				scuffed = {},
			}

# Every removal is one of three things to a column: ground coming off its top (maybe
# the last of it — discovery), one of its own stones coming off (damage), or nothing to
# do with it.
func _on_tile_changed(layer: int, cell: Vector2i, _type: TileTypes.Type) -> void:
	if not _columns.has(cell):
		return
	var column: Dictionary = _columns[cell]
	if column.levels.has(layer):
		damaged += column.levels[layer]
		column.levels.erase(layer)
		changed.emit()
	else:
		_check_discovery(cell)

# Digging down to a column's top stone is what discovers it — the stone has to still be
# there, which is also why smashing the top course can never count as discovery: by the
# time the course below shows, the column was either already discovered or already
# damaged goods.
func _check_discovery(cell: Vector2i) -> void:
	var column: Dictionary = _columns[cell]
	if column.discovered or _terrain.top_level(cell) != column.top:
		return
	column.discovered = true
	discovered += column.points
	changed.emit()

# A blade came down on a stone the tool couldn't work. The stone stays; the mark on it
# doesn't wash off, and it's only ever paid for once — a player who keeps hammering the
# same corner is wasting time, not money.
func _on_stone_struck(cell: Vector2i) -> void:
	if not _columns.has(cell):
		return
	var column: Dictionary = _columns[cell]
	var level := _terrain.top_level(cell)
	if not column.levels.has(level) or column.scuffed.has(level):
		return
	column.scuffed[level] = true
	damaged += SCUFF_POINTS
	changed.emit()

func _on_artifact_taken(artifact: ArtifactData.Artifact) -> void:
	discovered += artifact.value
	changed.emit()

# The knocked-off value shows up as damage, and since the find now pays its lower price,
# the bar can no longer reach the top — a careless dig leaves a visible dent.
func _on_artifact_degraded(_artifact: ArtifactData.Artifact, lost: int) -> void:
	damaged += lost
	changed.emit()
