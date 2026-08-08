class_name ArtifactGenerator

const MIN_FINDS := 3
const MAX_FINDS := 6

# Finds are buried in the rooms of a ruin, resting on its floor — so they sit one level
# up from it, in the dirt that filled the place in. Digging that dirt out is what turns
# them up. Anywhere outside the outline there'd be no reason to dig for them.
static func bury(terrain: TerrainData) -> ArtifactData:
	var data := ArtifactData.new()
	data.name = "ArtifactData"
	data.bind(terrain)
	if terrain.structure == null:
		return data

	var cells := room_cells(terrain)
	cells.shuffle()
	for i in mini(randi_range(MIN_FINDS, MAX_FINDS), cells.size()):
		var entry := ArtifactTypes.pick_random()
		var artifact := ArtifactData.Artifact.new()
		artifact.cell = cells[i]
		artifact.level = TerrainLayers.STRUCTURE_FLOOR_LEVEL + 1
		artifact.value = entry.value
		artifact.file = entry.file
		data.add(artifact)
	return data

# The insides of the rooms, in world cells: floor with no wall standing on it.
static func room_cells(terrain: TerrainData) -> Array[Vector2i]:
	var structure := terrain.structure
	var cells: Array[Vector2i] = []
	for y in structure.size.y:
		for x in structure.size.x:
			var local := Vector2i(x, y)
			if not structure.is_floor(local) or structure.is_wall(0, local):
				continue
			var cell: Vector2i = terrain.structure_origin + local
			if terrain.is_inside(cell):
				cells.append(cell)
	return cells
