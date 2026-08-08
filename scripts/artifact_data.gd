class_name ArtifactData extends Node

# One find sitting in the ground at one cell of one level. Digging never destroys it: the
# dig that would take away the level it lies in uncovers it instead, and it stays there
# until it's picked up.
class Artifact extends RefCounted:
	var cell: Vector2i
	var level: int
	var value: int
	var file: String
	var taken := false

signal artifact_unearthed(artifact: Artifact)
signal artifact_taken(artifact: Artifact)
# `lost` is the value knocked off — what careless digging cost.
signal artifact_degraded(artifact: Artifact, lost: int)

var artifacts: Array[Artifact] = []

var _terrain: TerrainData
# Only one find to a cell, which is also what makes looking one up a lookup.
var _by_cell := {}

func bind(terrain: TerrainData) -> void:
	_terrain = terrain
	terrain.tile_changed.connect(_on_tile_changed)

func add(artifact: Artifact) -> void:
	artifacts.append(artifact)
	_by_cell[artifact.cell] = artifact

# Dug down far enough to see: the level it was buried in is gone from this cell.
func is_unearthed(artifact: Artifact) -> bool:
	return _terrain.heightmap[artifact.cell.y][artifact.cell.x] < artifact.level

# The find lying in the open at this cell, if there is one. Still-buried finds don't
# count — there's nothing there to pick up yet.
func at(cell: Vector2i) -> Artifact:
	var artifact := buried_at(cell)
	if artifact == null or not is_unearthed(artifact):
		return null
	return artifact

# The find at this cell whether it shows yet or not — for whoever needs to know what's
# under the ground, like the cursor warning that a rough tool is about to hit it.
func buried_at(cell: Vector2i) -> Artifact:
	var artifact: Artifact = _by_cell.get(cell)
	if artifact == null or artifact.taken:
		return null
	return artifact

# A rough unearthing: the find turns into its damaged form and the difference is lost.
# It stays in the ground, pickable — just worth less than it was.
func degrade(artifact: Artifact) -> void:
	var worse := ArtifactTypes.degraded(artifact.file)
	var lost: int = artifact.value - worse.value
	if lost <= 0:
		return
	artifact.file = worse.file
	artifact.value = worse.value
	artifact_degraded.emit(artifact, lost)

func take(cell: Vector2i) -> Artifact:
	var artifact := at(cell)
	if artifact == null:
		return null
	artifact.taken = true
	_by_cell.erase(cell)
	artifact_taken.emit(artifact)
	return artifact

func _on_tile_changed(_layer: int, cell: Vector2i, _type: TileTypes.Type) -> void:
	var artifact: Artifact = _by_cell.get(cell)
	if artifact != null and not artifact.taken and is_unearthed(artifact):
		artifact_unearthed.emit(artifact)
