extends Node

# The expedition, autoloaded so it outlives every scene: which dig the player is on and
# what they've bought carries from level to summary to shop and back. Coins live next
# door in Wallet.

var level: int = 1

# What the shop sold, for it and the controller to read. Keyed by whatever the shop
# decides tools are; stays across levels.
var owned_tools := {}

# Each dig is a little bigger and a little busier than the last. The whole difficulty
# curve lives here: world.gd just asks.
func level_params() -> Dictionary:
	return {
		width = mini(15 + 3 * (level - 1), 36),
		height = mini(15 + 3 * (level - 1), 36),
		# 1, 1, 2, 2, 3, 3... — a second ruin from level 3, a third from level 5.
		structures = 1 + (level - 1) / 2,
	}

func advance() -> void:
	level += 1

# A fresh expedition from the menu: first dig, empty pockets back to the stake.
func reset() -> void:
	level = 1
	owned_tools.clear()
	Wallet.coins = Wallet.STARTING_COINS
