extends Label
## Grey-box readout: controls, current state, speed, and roll invincibility.

const CONTROLS := "Move: A/D or arrows   Jump: Space   Roll: Shift or K   (pad: stick, A, B)"


func _process(_delta: float) -> void:
	var players := get_tree().get_nodes_in_group(&"players")
	if players.is_empty():
		text = CONTROLS
		return
	var player := players[0] as Player
	if player == null:
		text = CONTROLS
		return
	text = (
		"%s\nstate: %s   speed: %d, %d   i-frames: %s"
		% [
			CONTROLS,
			player.machine.current_name(),
			roundi(player.velocity.x),
			roundi(player.velocity.y),
			"ON" if player.invincible else "off",
		]
	)
