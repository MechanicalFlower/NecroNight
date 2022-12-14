extends Spatial

# Get character's node path
export(NodePath) var character

# Get head's node path
export(NodePath) var head

# Get camera's node path
export(NodePath) var neck

# Get camera's node path
export(NodePath) var camera

# Load weapon class for make weapons
var weapon = load("res://scripts/weapon/weapon.gd")

# All weapons
var arsenal: Dictionary

# Current weapon
var current: int = 0

# Dict of inputs
var input: Dictionary = {}

onready var input_wrapper := get_node("%Input") as InputWrapper


func _ready() -> void:
	set_as_toplevel(true)

	# Get camera node from path
	camera = get_node(camera)

	# Get neck node from path
	neck = get_node(neck)

	# Get head node from path
	head = get_node(head)

	# Get head node from path
	character = get_node(character)

	# Class reference :
	# owner, name, firerate, bullets, ammo, max_bullets, damage, reload_speed;

	# Create mk 23 using weapon classs
	arsenal["mk_23"] = weapon.Weapon.new(self, "mk_23", 2.0, 12, 999, 12, 40, 1.2)

	# Create glock 17 using weapon class
	arsenal["glock_17"] = weapon.Weapon.new(self, "glock_17", 3.0, 12, 999, 12, 35, 1.2)

	# Create kriss using weapon class
	arsenal["kriss"] = weapon.Weapon.new(self, "kriss", 6.0, 32, 999, 33, 25, 1.5)

	for w in arsenal:
		arsenal.values()[current].hide()


func _physics_process(_delta) -> void:
	# Call weapon function
	_weapon(_delta)
	_change()
	_position(_delta)


func _weapon(_delta) -> void:
	input["shoot"] = int(input_wrapper.is_action_pressed("shoot"))
	input["reload"] = int(input_wrapper.is_action_pressed("reload"))
	input["zoom"] = int(input_wrapper.is_action_pressed("zoom"))

	arsenal.values()[current].sprint(character.input["sprint"] or character.input["jump"], _delta)

	if not character.input["sprint"] or not character.direction:
		if input["shoot"]:
			arsenal.values()[current].shoot(_delta)

		arsenal.values()[current].zoom(input["zoom"], _delta)

	if input["reload"]:
		arsenal.values()[current].reload()

	# Update arsenal
	for w in range(arsenal.size()):
		arsenal.values()[w].update(_delta)


func _change() -> void:
	# change weapons
	for w in range(arsenal.size()):
		if arsenal.values()[w] != arsenal.values()[current]:
			arsenal.values()[w].hide()
		else:
			arsenal.values()[w].draw()


func _position(_delta) -> void:
	var y_lerp = 20
	var x_lerp = 40

	global_transform.origin = head.global_transform.origin

	if not input["zoom"]:
		rotation.x = lerp_angle(
			rotation.x, camera.global_transform.basis.get_euler().x, y_lerp * _delta
		)
		rotation.y = lerp_angle(
			rotation.y, camera.global_transform.basis.get_euler().y, x_lerp * _delta
		)
	else:
		rotation = camera.global_transform.basis.get_euler()


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			var anim = arsenal.values()[current].anim

			if not anim.is_playing():
				if event.scancode == KEY_KP_1:
					current = 0
				if event.scancode == KEY_KP_2:
					current = 1
				if event.scancode == KEY_KP_3:
					current = 2
