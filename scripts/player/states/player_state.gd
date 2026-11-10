class_name PlayerState
extends State
## Base class for player states. Gives typed shortcuts to the player.

var player: Player:
	get:
		return actor as Player

var data: MovementData:
	get:
		return player.data

var input: InputComponent:
	get:
		return player.input
