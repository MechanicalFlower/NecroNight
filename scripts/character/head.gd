extends Spatial

export(NodePath) var character

export var sensibility: float = 0.2  # Mouse sensitivity
export var captured: bool = true  # Does not let the mouse leave the screen

var mouse_axis := Vector2.ZERO

onready var input_wrapper := get_node("%Input") as InputWrapper


func _ready():
	character = get_node(character)


func _physics_process(delta: float) -> void:
	var joystick_axis := input_wrapper.get_vector("lookleft", "lookright", "lookdown", "lookup")
	if joystick_axis != Vector2.ZERO:
		mouse_axis = joystick_axis * 1000.0 * delta
		_camera_rotation()


func _camera_rotation() -> void:
	var camera: Dictionary = {0: $".", 1: $"."}

	# Rotates the camera on the x axis
	camera[0].rotation.x += -deg2rad(mouse_axis.y * sensibility)

	# Rotates the camera on the y axis
	camera[1].rotation.y += -deg2rad(mouse_axis.x * sensibility)

	# Creates a limit for the camera on the x axis
	var max_angle: int = 85  # Maximum camera angle
	camera[0].rotation.x = min(camera[0].rotation.x, deg2rad(max_angle))
	camera[0].rotation.x = max(camera[0].rotation.x, -deg2rad(max_angle))


func _input(event) -> void:
	# If the mouse is locked
	if (
		input_wrapper._player_index == 0
		and event is InputEventMouseMotion
		and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	):
		mouse_axis = event.relative
		# Calls the function to rotate the camera
		_camera_rotation()
