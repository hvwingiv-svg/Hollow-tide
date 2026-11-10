@tool
extends Node2D
## Faint grid behind the room, for judging jump and roll distances by eye.

@export var area := Rect2(0.0, -200.0, 1600.0, 760.0)
@export var cell := 32.0
@export var color := Color(1.0, 1.0, 1.0, 0.05)


func _draw() -> void:
	if cell <= 0.0:
		return
	var x := area.position.x
	while x <= area.end.x:
		draw_line(Vector2(x, area.position.y), Vector2(x, area.end.y), color, 1.0)
		x += cell
	var y := area.position.y
	while y <= area.end.y:
		draw_line(Vector2(area.position.x, y), Vector2(area.end.x, y), color, 1.0)
		y += cell
