class_name ArtifactTypes

const DIRECTORY := "res://images/artifacts/"

# Everything a find is worth knowing: the picture, what it pays, and how often it turns
# up. Weight is relative to the other rows — weight 12 against weight 1 means twelve
# turn up for every one. Broken things are common and cheap, whole ones are neither.
# `damaged` names the row a find turns into when unearthed roughly; rows without one
# keep their picture and lose half their value instead. Add a row and it's in the game.
const CATALOGUE := [
	# What the ground gives up by the handful: bones and shells, nobody's treasure.
	{file = "kosc1.png", value = 5, weight = 12},
	{file = "kosc2.png", value = 5, weight = 12},
	{file = "Muszla1.png", value = 6, weight = 11},
	{file = "Muszla2.png", value = 6, weight = 11},
	{file = "grot1.png", value = 8, weight = 10},
	{file = "grot2.png", value = 8, weight = 10},

	# Things that were made, and then broken.
	{file = "noz uszkodzony.png", value = 10, weight = 8},
	{file = "kolo uszkodzone.png", value = 12, weight = 7},
	{file = "totem uszkodzony.png", value = 15, weight = 6},

	# The same things, whole. Dug up roughly, each falls back to its broken row above.
	{file = "noz.png", value = 20, weight = 5, damaged = "noz uszkodzony.png"},
	{file = "kolo.png", value = 25, weight = 4, damaged = "kolo uszkodzone.png"},
	{file = "Figurka1.png", value = 28, weight = 3},
	{file = "Figurka2.png", value = 28, weight = 3},
	{file = "totem1.png", value = 30, weight = 3, damaged = "totem uszkodzony.png"},
	{file = "totem2.png", value = 30, weight = 3, damaged = "totem uszkodzony.png"},

	# The coins spell one word between them. Priced as a middling find each, and rare
	# enough that seeing all five in one run means something.
	{file = "Moneta e.png", value = 18, weight = 2},
	{file = "Moneta r.png", value = 18, weight = 2},
	{file = "Moneta w.png", value = 18, weight = 2},
	{file = "Moneta o.png", value = 18, weight = 2},
	{file = "Moneta n.png", value = 18, weight = 2},

	{file = "pierscionek.png", value = 40, weight = 2},
	{file = "Koło mamona .png", value = 45, weight = 2},

	# The jokes. One in a hundred-odd digs, and worth the whole level when it lands.
	{file = "Reksio.png", value = 90, weight = 1},
	{file = "ewron dwukropek trzy.png", value = 100, weight = 1},
	{file = "Stary wrócił .png", value = 110, weight = 1},
	{file = "ZUPAAAAAAAA.png", value = 120, weight = 1},
]

# What a rough dig turns a find into: its damaged counterpart when the sheet has one,
# otherwise the same thing worth half as much.
static func degraded(file: String) -> Dictionary:
	var entry := find(file)
	if entry.has("damaged"):
		return find(entry.damaged)
	return {file = entry.file, value = maxi(1, entry.value / 2)}

static func find(file: String) -> Dictionary:
	for entry in CATALOGUE:
		if entry.file == file:
			return entry
	return CATALOGUE[0]

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
