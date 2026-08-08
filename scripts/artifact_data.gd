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
	var artifact: Artifact = _by_cell.get(cell)
	if artifact == null or artifact.taken or not is_unearthed(artifact):
		return null
	return artifact

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
