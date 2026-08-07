class_name DualGridTerrain
extends Node2D

## Dual-grid terrain renderer.
##
## World data lives in a flat array. The visual TileMapLayer is offset by half a
## tile, so each display tile reads the four world cells meeting at its corners
## and picks one of 16 tiles.
##
## Assign `display` to a TileMapLayer whose TileSet contains your 16-tile atlas,
## then edit TILES below to match that atlas's layout.

signal cell_changed(cell: Vector2i, filled: bool)

@export var display: TileMapLayer
@export var size := Vector2i(64, 64)
@export var source_id := 0

## When true, cells outside the map count as filled, so terrain runs off the
## edge instead of drawing a hard border.
@export var solid_outside := false

# World cells sampled by a display tile, in bitmask order: TL, TR, BL, BR.
const CORNERS: Array[Vector2i] = [
	Vector2i(-1, -1), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 0),
]

# Display tiles affected by a change to a single world cell.
const AFFECTED: Array[Vector2i] = [
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1),
]

# Bitmask (1 = TL, 2 = TR, 4 = BL, 8 = BR) -> atlas coordinates.
# These values assume a 4x4 sheet; replace them with your own.
const TILES := {
	0: Vector2i(0, 3), 1: Vector2i(3, 3), 2: Vector2i(0, 2), 3: Vector2i(1, 3),
	4: Vector2i(3, 0), 5: Vector2i(2, 3), 6: Vector2i(3, 2), 7: Vector2i(1, 2),
	8: Vector2i(0, 0), 9: Vector2i(0, 1), 10: Vector2i(1, 0), 11: Vector2i(2, 0),
	12: Vector2i(3, 1), 13: Vector2i(2, 1), 14: Vector2i(1, 1), 15: Vector2i(2, 2),
}

var _cells := PackedByteArray()


func _ready() -> void:
	assert(display != null, "DualGridTerrain needs a display TileMapLayer.")
	_cells.resize(size.x * size.y)
	display.position = -Vector2(display.tile_set.tile_size) * 0.5
	refresh_all()


# --- Queries -----------------------------------------------------------------

func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < size.x and cell.y < size.y


func is_filled(cell: Vector2i) -> bool:
	if not in_bounds(cell):
		return solid_outside
	return _cells[cell.y * size.x + cell.x] != 0


## Converts a global position to a world cell. Use this for mouse input rather
## than display.local_to_map(), which is off by half a tile.
func global_to_cell(global_pos: Vector2) -> Vector2i:
	var local := to_local(global_pos)
	return Vector2i((local / Vector2(display.tile_set.tile_size)).floor())


# --- Mutation ----------------------------------------------------------------

func set_cell(cell: Vector2i, filled: bool) -> void:
	if not in_bounds(cell) or is_filled(cell) == filled:
		return
	_cells[cell.y * size.x + cell.x] = 1 if filled else 0
	for offset in AFFECTED:
		_refresh(cell + offset)
	cell_changed.emit(cell, filled)


## Batch edit. Dedupes the redraw so shared borders aren't rebuilt twice.
func set_cells(cells: Array, filled: bool) -> void:
	var dirty := {}
	for cell in cells:
		if not in_bounds(cell) or is_filled(cell) == filled:
			continue
		_cells[cell.y * size.x + cell.x] = 1 if filled else 0
		for offset in AFFECTED:
			dirty[cell + offset] = true
		cell_changed.emit(cell, filled)
	for d in dirty:
		_refresh(d)


func fill_rect(rect: Rect2i, filled: bool) -> void:
	var cells := []
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			cells.append(Vector2i(x, y))
	set_cells(cells, filled)


func clear() -> void:
	_cells.fill(0)
	refresh_all()


## Rebuilds every display tile. The display grid is one cell larger than the
## world grid in each direction, since it straddles the outer edges.
func refresh_all() -> void:
	for y in range(size.y + 1):
		for x in range(size.x + 1):
			_refresh(Vector2i(x, y))


# --- Internals ---------------------------------------------------------------

func _mask(d: Vector2i) -> int:
	var mask := 0
	for i in 4:
		if is_filled(d + CORNERS[i]):
			mask |= 1 << i
	return mask


func _refresh(d: Vector2i) -> void:
	display.set_cell(d, source_id, TILES[_mask(d)])
