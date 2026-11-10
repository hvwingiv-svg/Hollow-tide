class_name Player
extends CharacterBody2D
## The player body. Its origin is at the feet.
##
## Each physics frame: read input, let the current state set velocity, then
## move. States live under the StateMachine child and call the helpers here.
## Nothing outside this scene should reach for "the" player; use the
## "players" group instead, so a second player can be added later.

const COLOR_NORMAL := Color(0.86, 0.88, 0.9)
const COLOR_INVINCIBLE := Color(0.25, 0.8, 0.75)
const ROLL_SQUASH := 0.55

@export var data: MovementData
## Falling below this y sends the player back to where they started.
@export var fall_limit := 640.0

## 1 when facing right, -1 when facing left.
var facing := 1
## True during the invincible part of a roll. Hurtboxes will read this.
var invincible := false
var coyote_timer := 0.0
var jump_cut_available := false

var _spawn_point := Vector2.ZERO

@onready var input: InputComponent = $InputComponent
@onready var machine: StateMachine = $StateMachine
@onready var visual: Node2D = $Visual
@onready var body: Polygon2D = $Visual/Body


func _ready() -> void:
	if data == null:
		data = MovementData.new()
	_spawn_point = global_position
	machine.setup(self)


func _physics_process(delta: float) -> void:
	input.tick(delta)
	machine.physics_update(delta)
	move_and_slide()
	if global_position.y > fall_limit:
		respawn()
	_update_visual()


func apply_gravity(delta: float) -> void:
	if is_on_floor():
		return
	var gravity_scale := data.fall_gravity_scale if velocity.y > 0.0 else 1.0
	velocity.y = minf(velocity.y + data.rise_gravity() * gravity_scale * delta, data.max_fall_speed)


## Moves horizontal speed toward axis * run_speed and updates facing.
func move_horizontal(axis: float, accel: float, delta: float) -> void:
	velocity.x = move_toward(velocity.x, axis * data.run_speed, accel * delta)
	if axis > 0.0:
		facing = 1
	elif axis < 0.0:
		facing = -1


func start_jump() -> void:
	velocity.y = -data.jump_velocity()
	coyote_timer = 0.0
	jump_cut_available = true


## Jumps if a jump press is buffered and the player is on, or just left, the
## ground. Returns true if it jumped.
func try_jump() -> bool:
	if coyote_timer <= 0.0:
		return false
	if not input.consume_jump():
		return false
	start_jump()
	machine.transition_to(&"Air")
	return true


## Rolls if a roll press is buffered and the player is on the ground.
## Returns true if it rolled.
func try_roll() -> bool:
	if not is_on_floor():
		return false
	if not input.consume_roll():
		return false
	machine.transition_to(&"Roll")
	return true


func respawn() -> void:
	global_position = _spawn_point
	velocity = Vector2.ZERO
	invincible = false
	machine.transition_to(&"Air")


func _update_visual() -> void:
	var rolling := machine.current_name() == &"Roll"
	visual.scale = Vector2(facing, ROLL_SQUASH if rolling else 1.0)
	body.color = COLOR_INVINCIBLE if invincible else COLOR_NORMAL
