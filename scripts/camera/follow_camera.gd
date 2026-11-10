extends Camera2D
## Follows the midpoint of every node in the "players" group, so it works
## unchanged for one player or two.

@export var group := &"players"
## How far the camera leads in the direction the players face.
@export var look_ahead := 24.0
## Shifts the view up so more of the screen is above the floor.
@export var vertical_offset := -80.0
## Higher is snappier. 0 disables smoothing.
@export var smoothing := 8.0


func _ready() -> void:
	var target := _target()
	if target != Vector2.INF:
		global_position = target


func _physics_process(delta: float) -> void:
	var target := _target()
	if target == Vector2.INF:
		return
	if smoothing <= 0.0:
		global_position = target
	else:
		global_position = global_position.lerp(target, 1.0 - exp(-smoothing * delta))


## Where the camera wants to be, or Vector2.INF if there are no players.
func _target() -> Vector2:
	var players := get_tree().get_nodes_in_group(group)
	if players.is_empty():
		return Vector2.INF

	var midpoint := Vector2.ZERO
	var facing_sum := 0.0
	for node in players:
		var player := node as Node2D
		if player == null:
			continue
		midpoint += player.global_position
		if "facing" in player:
			facing_sum += float(player.get("facing"))
	midpoint /= float(players.size())

	midpoint.x += look_ahead * clampf(facing_sum, -1.0, 1.0)
	midpoint.y += vertical_offset
	return midpoint
