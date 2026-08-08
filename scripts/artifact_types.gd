class_name ArtifactTypes

const DIRECTORY := "res://images/artifacts/"

# Everything a find is worth knowing: the picture, what it pays, and how often it turns
# up. Weight is relative to the other rows — weight 12 against weight 1 means twelve
# turn up for every one. Broken things are common and cheap, whole ones are neither.
# Add a row and it's in the game.
const CATALOGUE := [
	{file = "kosc1.png", value = 5, weight = 12},
	{file = "kosc2.png", value = 5, weight = 12},
	{file = "grot1.png", value = 8, weight = 10},
	{file = "grot2.png", value = 8, weight = 10},
	{file = "noz uszkodzony.png", value = 10, weight = 8},
	{file = "kolo uszkodzone.png", value = 12, weight = 7},
	{file = "totem uszkodzony.png", value = 15, weight = 6},
	{file = "noz.png", value = 20, weight = 5},
	{file = "kolo.png", value = 25, weight = 4},
	{file = "totem1.png", value = 30, weight = 3},
	{file = "totem2.png", value = 30, weight = 3},
	{file = "pierscionek.png", value = 40, weight = 2},
	{file = "ewron dwukropek trzy.png", value = 100, weight = 1},
]

static func pick_random() -> Dictionary:
	var total := 0
	for entry in CATALOGUE:
		total += entry.weight
	var roll := randi_range(1, total)
	for entry in CATALOGUE:
		roll -= entry.weight
		if roll <= 0:
			return entry
	return CATALOGUE[0]

static func texture(file: String) -> Texture2D:
	return load(DIRECTORY + file)
