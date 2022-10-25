class_name InputWrapper

extends Node

var _player_index: int
var _action_suffix: String


func _ready():
	_player_index = InputManager.add_player()
	_action_suffix = str(_player_index)


func get_vector(
	negative_x: String,
	positive_x: String,
	negative_y: String,
	positive_y: String,
	deadzone: float = -1.0
) -> Vector2:
	return Input.get_vector(
		negative_x + _action_suffix,
		positive_x + _action_suffix,
		negative_y + _action_suffix,
		positive_y + _action_suffix,
		deadzone
	)


func is_action_just_pressed(action: String, exact: bool = false) -> bool:
	return Input.is_action_just_pressed(action + _action_suffix, exact)


func is_action_pressed(action: String, exact: bool = false) -> bool:
	return Input.is_action_pressed(action + _action_suffix, exact)
