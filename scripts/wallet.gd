extends Node

# The player's money, autoloaded so it outlives the scene it was earned in: the site is
# where coins come from and the shop is where they go, and neither has to hand them to
# the other.

signal coins_changed(coins: int)

const STARTING_COINS := 100

var coins: int = STARTING_COINS

func add(amount: int) -> void:
	coins += amount
	coins_changed.emit(coins)

# Refuses rather than going into debt, so a caller can use it as the check as well:
# `if Wallet.spend(10): ...`
func spend(amount: int) -> bool:
	if amount > coins:
		return false
	coins -= amount
	coins_changed.emit(coins)
	return true
