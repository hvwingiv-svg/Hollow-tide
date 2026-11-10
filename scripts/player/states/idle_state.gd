extends PlayerState
## Standing on the ground with no movement input.


func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.move_horizontal(0.0, data.ground_decel, delta)

	if not player.is_on_floor():
		machine.transition_to(&"Air")
		return

	player.coyote_timer = data.coyote_time
	if player.try_jump() or player.try_roll():
		return
	if input.move_axis != 0.0:
		machine.transition_to(&"Run")
