@tool
class_name GreyboxBlock
extends StaticBody2D
## A placeholder rectangle of solid ground. Position is its top-left corner.
## Set size in the inspector; the collision shape and drawing follow.

@export var size := Vector2(64.0, 16.0):
	set(value):
		size = value
		_rebuild()

@export var color := Color(0.33, 0.36, 0.4):
	set(value):
		color = value
		queue_redraw()

## One-way platforms can be jumped through from below.
@export var one_way := false:
	set(value):
		one_way = value
		_rebuild()

var _collision: CollisionShape2D


func _ready() -> void:
	_rebuild()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), color)


func _rebuild() -> void:
	if not is_node_ready():
		return
	if _collision == null:
		_collision = CollisionShape2D.new()
		_collision.shape = RectangleShape2D.new()
		add_child(_collision)
	var rectangle := _collision.shape as RectangleShape2D
	rectangle.size = size
	_collision.position = size / 2.0
	_collision.one_way_collision = one_way
	queue_redraw()
