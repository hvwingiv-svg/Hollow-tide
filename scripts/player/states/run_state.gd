extends PlayerState
## Moving along the ground.


func physics_update(delta: float) -> void:
	player.apply_gravity(delta)

	var axis := input.move_axis
	var reversing := axis * player.velocity.x < 0.0
	var accel := data.ground_accel
	if axis == 0.0 or reversing:
		accel = data.ground_decel
	player.move_horizontal(axis, accel, delta)

	if not player.is_on_floor():
		machine.transition_to(&"Air")
		return

	player.coyote_timer = data.coyote_time
	if player.try_jump() or player.try_roll():
		return
	if axis == 0.0 and is_zero_approx(player.velocity.x):
		machine.transition_to(&"Idle")
