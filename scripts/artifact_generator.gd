class_name ArtifactGenerator

const MIN_FINDS_PER_RUIN := 3
const MAX_FINDS_PER_RUIN := 6

# Finds are buried in the rooms of the ruins, resting on their floors — so they sit one
# level up from it, in the dirt that filled the place in. Digging that dirt out is what
# turns them up. Anywhere outside the outlines there'd be no reason to dig for them.
static func bury(terrain: TerrainData, finds_per_ruin: int = -1) -> ArtifactData:
	var data := ArtifactData.new()
	data.name = "ArtifactData"
	data.bind(terrain)

	for placed in terrain.structures:
		var cells := room_cells(placed)
		cells.shuffle()
		var count := finds_per_ruin
		if count < 0:
			count = randi_range(MIN_FINDS_PER_RUIN, MAX_FINDS_PER_RUIN)
		for i in mini(count, cells.size()):
			var entry := ArtifactTypes.pick_random()
			var artifact := ArtifactData.Artifact.new()
			artifact.cell = cells[i]
			artifact.level = TerrainLayers.STRUCTURE_FLOOR_LEVEL + 1
			artifact.value = entry.value
			artifact.file = entry.file
			data.add(artifact)
	return data

# The insides of a ruin's rooms, in world cells: floor with no wall standing on it.
static func room_cells(placed: TerrainData.PlacedStructure) -> Array[Vector2i]:
	var structure := placed.structure
	var cells: Array[Vector2i] = []
	for y in structure.size.y:
		for x in structure.size.x:
			var local := Vector2i(x, y)
			if structure.is_floor(local) and not structure.is_wall(0, local):
				cells.append(placed.origin + local)
	return cells
