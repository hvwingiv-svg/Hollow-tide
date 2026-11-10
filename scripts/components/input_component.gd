class_name InputComponent
extends Node
## Reads one player's actions and buffers button presses.
##
## The owner calls tick() once per physics frame, before its state machine
## runs. Buffered presses stay valid for buffer_time seconds, so a jump or
## roll pressed slightly early still fires.

@export var player_index := 0
@export var buffer_time := 0.15

var move_axis := 0.0

var _jump_buffer := 0.0
var _roll_buffer := 0.0

var _left: StringName
var _right: StringName
var _jump: StringName
var _roll: StringName


func _ready() -> void:
	_left = InputSetup.action_name(player_index, "left")
	_right = InputSetup.action_name(player_index, "right")
	_jump = InputSetup.action_name(player_index, "jump")
	_roll = InputSetup.action_name(player_index, "roll")


func tick(delta: float) -> void:
	move_axis = Input.get_axis(_left, _right)

	_jump_buffer = maxf(_jump_buffer - delta, 0.0)
	_roll_buffer = maxf(_roll_buffer - delta, 0.0)
	if Input.is_action_just_pressed(_jump):
		_jump_buffer = buffer_time
	if Input.is_action_just_pressed(_roll):
		_roll_buffer = buffer_time


func is_jump_held() -> bool:
	return Input.is_action_pressed(_jump)


## True once per buffered jump press. Calling it uses the press up.
func consume_jump() -> bool:
	if _jump_buffer <= 0.0:
		return false
	_jump_buffer = 0.0
	return true


## True once per buffered roll press. Calling it uses the press up.
func consume_roll() -> bool:
	if _roll_buffer <= 0.0:
		return false
	_roll_buffer = 0.0
	return true
