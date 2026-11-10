extends Node
## Autoload. Registers input actions in code, one set per player index.
##
## Actions are named "p1_left", "p1_jump", "p2_left" and so on, so a second
## player later is one extra register_player() call. Player 1 gets the
## keyboard plus gamepad 0; every later player gets the gamepad matching
## their index.

const DEADZONE := 0.3


func _ready() -> void:
	register_player(0)


## Name of an action for a player, e.g. action_name(0, "jump") -> "p1_jump".
func action_name(player_index: int, base: String) -> StringName:
	return StringName("p%d_%s" % [player_index + 1, base])


func register_player(player_index: int) -> void:
	var pad := player_index
	var use_keyboard := player_index == 0

	var left: Array = [
		_pad_button(pad, JOY_BUTTON_DPAD_LEFT),
		_pad_axis(pad, JOY_AXIS_LEFT_X, -1.0),
	]
	var right: Array = [
		_pad_button(pad, JOY_BUTTON_DPAD_RIGHT),
		_pad_axis(pad, JOY_AXIS_LEFT_X, 1.0),
	]
	var jump: Array = [_pad_button(pad, JOY_BUTTON_A)]
	var roll: Array = [_pad_button(pad, JOY_BUTTON_B)]

	if use_keyboard:
		left.append(_key(KEY_A))
		left.append(_key(KEY_LEFT))
		right.append(_key(KEY_D))
		right.append(_key(KEY_RIGHT))
		jump.append(_key(KEY_SPACE))
		roll.append(_key(KEY_SHIFT))
		roll.append(_key(KEY_K))

	_bind(player_index, "left", left)
	_bind(player_index, "right", right)
	_bind(player_index, "jump", jump)
	_bind(player_index, "roll", roll)


func _bind(player_index: int, base: String, events: Array) -> void:
	var action := action_name(player_index, base)
	if InputMap.has_action(action):
		InputMap.erase_action(action)
	InputMap.add_action(action, DEADZONE)
	for event: InputEvent in events:
		InputMap.action_add_event(action, event)


func _key(code: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = code
	return event


func _pad_button(device: int, button: JoyButton) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.device = device
	event.button_index = button
	return event


func _pad_axis(device: int, axis: JoyAxis, direction: float) -> InputEventJoypadMotion:
	var event := InputEventJoypadMotion.new()
	event.device = device
	event.axis = axis
	event.axis_value = direction
	return event
