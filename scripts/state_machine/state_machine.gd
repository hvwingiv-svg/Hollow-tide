class_name StateMachine
extends Node
## Runs exactly one child State at a time. Shared by the player and, later,
## every enemy.

signal state_changed(from: StringName, to: StringName)

@export var initial_state: NodePath

var current: State

var _states: Dictionary = {}


## Call once from the owner's _ready().
func setup(actor: Node) -> void:
	for child in get_children():
		if child is State:
			var state := child as State
			state.actor = actor
			state.machine = self
			_states[StringName(state.name)] = state

	current = get_node_or_null(initial_state) as State
	if current == null:
		push_error("StateMachine on %s has no valid initial_state." % actor.name)
		return
	current.enter(&"")


func physics_update(delta: float) -> void:
	if current != null:
		current.physics_update(delta)


func transition_to(target: StringName) -> void:
	if not _states.has(target):
		push_error("StateMachine: unknown state '%s'." % target)
		return
	var next: State = _states[target]
	if next == current:
		return

	var previous := current_name()
	if current != null:
		current.exit()
	current = next
	current.enter(previous)
	state_changed.emit(previous, target)


func current_name() -> StringName:
	if current == null:
		return &""
	return StringName(current.name)
