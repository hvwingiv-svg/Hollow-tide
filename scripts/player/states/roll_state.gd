extends PlayerState
## Dodge roll. Committed: no steering, no cancelling. Invincible at the start.

var _time := 0.0
var _direction := 1


func enter(_previous: StringName) -> void:
	_time = 0.0
	if input.move_axis > 0.0:
		_direction = 1
	elif input.move_axis < 0.0:
		_direction = -1
	else:
		_direction = player.facing
	player.facing = _direction
	player.invincible = true
	# No coyote jump out of a roll that carries the player off a ledge.
	player.coyote_timer = 0.0


func exit() -> void:
	player.invincible = false


func physics_update(delta: float) -> void:
	_time += delta
	player.invincible = _time <= data.roll_iframe_duration

	# Fast at the start, easing down to run speed so the exit feels smooth.
	var progress := clampf(_time / data.roll_duration, 0.0, 1.0)
	var speed := lerpf(data.roll_speed, data.roll_end_speed, progress * progress)
	player.velocity.x = _direction * speed
	player.apply_gravity(delta)

	if _time < data.roll_duration:
		return
	if not player.is_on_floor():
		machine.transition_to(&"Air")
	elif input.move_axis != 0.0:
		machine.transition_to(&"Run")
	else:
		machine.transition_to(&"Idle")
