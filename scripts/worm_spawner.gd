class_name WormSpawner extends Node2D

# Worms turn up in disturbed earth. Watches the digging the same way the ScoreCard does —
# nothing calls in here, so no tool and no renderer has to remember to ask for a worm.
# They're parented to this node, which keeps them out of the terrain's own tree.

const WORM_SCENE := preload("res://scenes/dzdzownica.tscn")

# Per tile of soil removed, not per swing: the shovel clears nine cells at a time, so a
# chance that reads fine per click turns into a swarm here.
@export var chance := 0.05

var _renderer: TerrainRenderer

func bind(terrain: TerrainData, renderer: TerrainRenderer, controller: TerrainController) -> void:
	_renderer = renderer
	terrain.tile_changed.connect(_on_tile_changed)
	controller.swing_landed.connect(_on_swing_landed)

# A worm caught under the swing doesn't get out of the way. Which cell it's on is decided
# by where it is right now, not by where it was dug up: they crawl, and the ground they
# crawl onto has usually long stopped changing.
func _on_swing_landed(cells: Array[Vector2i]) -> void:
	for worm: Dzdzownica in get_children():
		if cells.has(_renderer.cell_at_global(worm.global_position)):
			worm.die()

func _on_tile_changed(_level: int, cell: Vector2i, removed: TileTypes.Type) -> void:
	# Nothing lives in the stonework, so breaking a ruin turns nothing up.
	if TerrainLayers.is_structure_material(removed):
		return
	if randf() >= chance:
		return
	var worm := WORM_SCENE.instantiate() as Dzdzownica
	add_child(worm)
	# global_at_cell rather than a tilemap's map_to_local: the tilemap layers carry the
	# half-tile display offset on purpose, so map_to_local would put the worm on the
	# corner of the hole instead of in it. Set after add_child, when global means something.
	worm.global_position = _renderer.global_at_cell(cell)
