class_name MovementData
extends Resource
## Every movement tuning number in one place. Edit data/player_movement.tres
## in the inspector to retune the feel without touching code.
## Distances are in pixels at the 640 x 360 base resolution; times in seconds.

@export_group("Run")
@export var run_speed := 120.0
@export var ground_accel := 900.0
@export var ground_decel := 1400.0

@export_group("Jump")
## Height of a full jump.
@export var jump_height := 52.0
## Time from leaving the ground to the top of a full jump.
@export var jump_time_to_apex := 0.36
## Gravity multiplier while falling. Above 1 makes the fall snappier.
@export var fall_gravity_scale := 1.5
@export var max_fall_speed := 420.0
## Upward speed is multiplied by this when jump is released early.
@export var jump_cut_factor := 0.5
## Grace period for jumping after walking off a ledge.
@export var coyote_time := 0.10
@export var air_accel := 700.0
@export var air_decel := 300.0

@export_group("Roll")
@export var roll_duration := 0.45
## The roll is invincible from its start for this long.
@export var roll_iframe_duration := 0.20
@export var roll_speed := 210.0
## Speed the roll eases down to by its last frame.
@export var roll_end_speed := 120.0


## Gravity while rising, derived from jump height and time to apex.
func rise_gravity() -> float:
	return 2.0 * jump_height / (jump_time_to_apex * jump_time_to_apex)


## Launch speed of a full jump, derived from jump height and time to apex.
func jump_velocity() -> float:
	return 2.0 * jump_height / jump_time_to_apex
