class_name State
extends Node
## Base class for one state. Add states as children of a StateMachine node;
## the node's name is the state's name.

var actor: Node
var machine: StateMachine


func enter(_previous: StringName) -> void:
	pass


func exit() -> void:
	pass


func physics_update(_delta: float) -> void:
	pass
