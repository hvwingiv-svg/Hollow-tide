extends Node2D
## On-screen touch controls for one player: left and right on the bottom left,
## roll and jump on the bottom right. Positions are in 640 x 360 viewport
## pixels, so this node belongs on a CanvasLayer.
##
## Touches drive the same input actions as the keyboard and gamepad, so the
## player code does not know the difference. The buttons hide as soon as a
## key or gamepad button is pressed and come back on the next touch.

const BUTTONS: Array[String] = ["left", "right", "jump", "roll"]

## Any touch that starts in this zone is a movement thumb. Left of the split
## is "left", right of it is "right", and the thumb can slide between them.
const MOVE_ZONE := Rect2(0.0, 232.0, 172.0, 128.0)
const MOVE_SPLIT_X := 78.0
const LEFT_CENTER := Vector2(44.0, 314.0)
const RIGHT_CENTER := Vector2(112.0, 314.0)
const MOVE_RADIUS := 26.0

const JUMP_CENTER := Vector2(594.0, 304.0)
const JUMP_RADIUS := 30.0
const ROLL_CENTER := Vector2(526.0, 326.0)
const ROLL_RADIUS := 24.0
## Round buttons accept touches a little outside their drawn edge.
const HIT_SCALE := 1.3

@export var player_index := 0
## Keep the buttons on screen even while a keyboard or gamepad is in use.
@export var always_visible := false
@export_range(0.05, 1.0) var opacity := 0.3

## Touch index -> the button that finger is on ("" for none).
var _touches: Dictionary = {}
## Buttons currently held down by at least one finger.
var _held: Dictionary = {}


func _ready() -> void:
	visible = always_visible or DisplayServer.is_touchscreen_available()


func _exit_tree() -> void:
	_release_all()


func _notification(what: int) -> void:
	# A finger lifted while the window is unfocused never sends a release.
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_release_all()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := make_input_local(event) as InputEventScreenTouch
		visible = true
		if touch.pressed:
			_touches[touch.index] = button_at(touch.position, "")
		else:
			_touches.erase(touch.index)
		_sync_actions()
	elif event is InputEventScreenDrag:
		var drag := make_input_local(event) as InputEventScreenDrag
		if _touches.has(drag.index):
			_touches[drag.index] = button_at(drag.position, _touches[drag.index])
			_sync_actions()
	elif not always_visible and _is_physical_press(event):
		_release_all()
		visible = false


func _draw() -> void:
	_draw_button(LEFT_CENTER, MOVE_RADIUS, _held.has("left"))
	_draw_arrow(LEFT_CENTER, -1.0)
	_draw_button(RIGHT_CENTER, MOVE_RADIUS, _held.has("right"))
	_draw_arrow(RIGHT_CENTER, 1.0)
	_draw_button(ROLL_CENTER, ROLL_RADIUS, _held.has("roll"))
	_draw_label(ROLL_CENTER, ROLL_RADIUS, "ROLL")
	_draw_button(JUMP_CENTER, JUMP_RADIUS, _held.has("jump"))
	_draw_label(JUMP_CENTER, JUMP_RADIUS, "JUMP")


## Which button a touch at this position is on. previous is the button the
## same finger was on before; a movement thumb stays a movement thumb even
## if it drifts out of the zone.
func button_at(point: Vector2, previous: String) -> String:
	if previous == "left" or previous == "right":
		return "left" if point.x < MOVE_SPLIT_X else "right"

	var jump_reach := point.distance_to(JUMP_CENTER) / (JUMP_RADIUS * HIT_SCALE)
	var roll_reach := point.distance_to(ROLL_CENTER) / (ROLL_RADIUS * HIT_SCALE)
	if jump_reach <= 1.0 or roll_reach <= 1.0:
		return "jump" if jump_reach <= roll_reach else "roll"

	if MOVE_ZONE.has_point(point):
		return "left" if point.x < MOVE_SPLIT_X else "right"
	return ""


## Presses and releases input actions so they match the fingers on screen.
func _sync_actions() -> void:
	var wanted: Dictionary = {}
	for button: String in _touches.values():
		if button != "":
			wanted[button] = true

	for button in BUTTONS:
		var action := InputSetup.action_name(player_index, button)
		if wanted.has(button) and not _held.has(button):
			Input.action_press(action)
			_held[button] = true
		elif not wanted.has(button) and _held.has(button):
			Input.action_release(action)
			_held.erase(button)
	queue_redraw()


func _release_all() -> void:
	_touches.clear()
	_sync_actions()


func _is_physical_press(event: InputEvent) -> bool:
	if event is InputEventKey:
		var key := event as InputEventKey
		return key.pressed and not key.echo
	if event is InputEventJoypadButton:
		return (event as InputEventJoypadButton).pressed
	return false


func _draw_button(center: Vector2, radius: float, pressed: bool) -> void:
	var fill := Color(1.0, 1.0, 1.0, opacity * (1.6 if pressed else 0.45))
	var outline := Color(1.0, 1.0, 1.0, minf(opacity * 2.2, 1.0))
	draw_circle(center, radius, fill)
	draw_arc(center, radius, 0.0, TAU, 48, outline, 1.0)


func _draw_arrow(center: Vector2, direction: float) -> void:
	var points := PackedVector2Array(
		[
			center + Vector2(direction * 10.0, 0.0),
			center + Vector2(direction * -6.0, -9.0),
			center + Vector2(direction * -6.0, 9.0),
		]
	)
	draw_colored_polygon(points, Color(1.0, 1.0, 1.0, minf(opacity * 2.2, 1.0)))


func _draw_label(center: Vector2, radius: float, text: String) -> void:
	var font_size := 8
	draw_string(
		ThemeDB.fallback_font,
		center + Vector2(-radius, 3.0),
		text,
		HORIZONTAL_ALIGNMENT_CENTER,
		radius * 2.0,
		font_size,
		Color(1.0, 1.0, 1.0, minf(opacity * 2.6, 1.0))
	)
