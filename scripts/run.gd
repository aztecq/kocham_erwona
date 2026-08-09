extends Node

# The expedition, autoloaded so it outlives every scene: which dig the player is on and
# what they've bought carries from level to summary to shop and back. Coins live next
# door in Wallet.

var level: int = 1

# What the shop sold and what the player is wearing because of it. Skins are cosmetic —
# every tool is in hand from the first dig, only its look is bought — so nothing outside
# the cursor has to read these. Keyed by ToolSkins ids; free skins are never listed,
# they're owned by being free.
var owned_skins := {}
# tool -> skin id. A tool missing from here is in the plain skin it started in.
var equipped_skins := {}

func owns_skin(id: StringName) -> bool:
	return ToolSkins.price(id) == 0 or owned_skins.has(id)

func unlock_skin(id: StringName) -> void:
	owned_skins[id] = true

# Puts a skin on its tool. Whatever it replaces stays bought, so the player can switch
# back and forth for free once both are paid for.
func equip_skin(id: StringName) -> void:
	equipped_skins[ToolSkins.tool_of(id)] = id

func skin_for(tool: ToolType.Type) -> StringName:
	return equipped_skins.get(tool, ToolSkins.default_for(tool))

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
	owned_skins.clear()
	equipped_skins.clear()
	Wallet.coins = Wallet.STARTING_COINS
