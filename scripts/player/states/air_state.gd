extends PlayerState
## Jumping or falling.


func physics_update(delta: float) -> void:
	if player.is_on_floor() and player.velocity.y >= 0.0:
		machine.transition_to(&"Run" if input.move_axis != 0.0 else &"Idle")
		return

	# Coyote time: a jump pressed just after leaving a ledge still counts.
	player.coyote_timer = maxf(player.coyote_timer - delta, 0.0)
	if player.try_jump():
		return

	player.apply_gravity(delta)

	# Releasing jump early cuts the rise short, once per jump.
	if player.jump_cut_available and player.velocity.y < 0.0 and not input.is_jump_held():
		player.velocity.y *= data.jump_cut_factor
		player.jump_cut_available = false

	var axis := input.move_axis
	player.move_horizontal(axis, data.air_accel if axis != 0.0 else data.air_decel, delta)
