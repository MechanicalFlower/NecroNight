tool

# TODO : make a post-generation to add tree and outdoor wall
# TODO : make a animation wrapper and manager

extends Spatial

enum Zone { ROOM, FOREST }

export(int) var _seed_value = null setget set_seed_value

export var level_size := Vector2(5, 5)
export var rooms_size := Vector2(4, 6)
export var rooms_max := 5

var Floor = preload("res://scenes/mansion/floor.tscn")
var Ceiling = preload("res://scenes/mansion/ceiling.tscn")
var Wall = preload("res://scenes/mansion/wall.tscn")
var WindowOpen = preload("res://scenes/mansion/window_open.tscn")
var WindowClose = preload("res://scenes/mansion/window_close.tscn")
var DoorOpen = preload("res://scenes/mansion/door_open.tscn")
var DoorWall = preload("res://scenes/mansion/doorway.tscn")
var DoorClose = preload("res://scenes/mansion/door_close.tscn")

var Tree = preload("res://assets/tree/models/tree01.fbx")

var _map = []


class ForestArea:
	pass


class RoomArea:
	var x: int
	var y: int
	var width: int
	var height: int

	var open_doors = []
	var door_walls = []
	var open_windows = []
	var close_windows = []

	var neighbor_up
	var neighbor_down
	var neighbor_left
	var neighbor_right

	func _init(room: Rect2):
		x = room.position.x
		y = room.position.y

		width = room.size.x
		height = room.size.y

	func setup(level_size: Vector2, _map):
		neighbor_up = get_neighbor(x, y - 1, level_size, _map)
		neighbor_down = get_neighbor(x, y + 1, level_size, _map)
		neighbor_left = get_neighbor(x - 1, y, level_size, _map)
		neighbor_right = get_neighbor(x + 1, y, level_size, _map)

		var x_global = x * width
		var y_global = y * height

		if neighbor_up is RoomArea:
			open_doors.append(Vector2(x_global + 4, y_global + 2))
		elif neighbor_up is ForestArea:
			close_windows.append(Vector2(x_global + 4, y_global + 2))

		if neighbor_down is RoomArea:
			door_walls.append(Vector2(x_global + 4, y_global + height))
		elif neighbor_down is ForestArea:
			close_windows.append(Vector2(x_global + 4, y_global + height))

		if neighbor_left is RoomArea:
			door_walls.append(Vector2(x_global + 2, y_global + 4))
		elif neighbor_left is ForestArea:
			close_windows.append(Vector2(x_global + 2, y_global + 4))

		if neighbor_right is RoomArea:
			open_doors.append(Vector2(x_global + width, y_global + 4))
		elif neighbor_right is ForestArea:
			close_windows.append(Vector2(x_global + width, y_global + 4))

	func get_neighbor(room_x, room_y, level_size, _map):
		if (0 > room_x or room_x >= level_size.x) or (0 > room_y or room_y >= level_size.y):
			return ForestArea.new()
		return _map[room_x][room_y]


func _ready() -> void:
	set_scale(Vector3.ONE * 1.75)

	if _seed_value == null:
		set_seed_value(randi())
	else:
		generate()


func generate() -> void:
	if _seed_value != null:
		seed(_seed_value)

	# Remove child
	for child in get_children():
		child.queue_free()

	create_map()


func set_seed_value(seed_value: int) -> void:
	_seed_value = seed_value

	# Re-generate
	generate()


func create_map():
	var map_width := int(level_size.x)
	var map_height := int(level_size.y)

	var rng := RandomNumberGenerator.new()
	rng.set_seed(_seed_value)

	var max_room_size := int(rooms_size.y)

	_map = []
	for _i in range(map_width):
		var new_col = []
		for _j in range(map_height):
			new_col.append(ForestArea.new())
		_map.append(new_col)

	for room in _generate_data(rng):
		_map[room.x][room.y] = RoomArea.new(Rect2(room.x, room.y, max_room_size, max_room_size))

	for i in range(map_width):
		for j in range(map_height):
			if _map[i][j] is ForestArea:
				create_forest(i * max_room_size, j * max_room_size)
			elif _map[i][j] is RoomArea:
				_map[i][j].setup(level_size, _map)
#				var width := rng.randi_range(rooms_size.x, rooms_size.y)
#				var height := rng.randi_range(rooms_size.x, rooms_size.y)
				# print(width, " ", height)

				create_room(
					_map[i][j], i * max_room_size, j * max_room_size, max_room_size, max_room_size
				)


func create_forest(room_x: int, room_y: int):
	var max_room_size = rooms_size.y

	var room_min_i = room_x + 2
	var room_max_i = room_x + max_room_size

	var room_min_j = room_y + 2
	var room_max_j = room_y + max_room_size

	for i in range(room_min_i, room_max_i + 1):
		for j in range(room_min_j, room_max_j + 1):
			if randi() % 20 == 0:
				var new_tree = Tree.instance()
				add_child(new_tree)
				new_tree.translate(Vector3(i, 1, j))


func create_room(room_area, room_x: int, room_y: int, room_width: int, room_height: int):
	var max_room_size = rooms_size.y

	if room_width % 2 == 1:
		room_width += 1
		if room_width > max_room_size:
			room_width -= 2

	if room_height % 2 == 1:
		room_height += 1
		if room_height > max_room_size:
			room_height -= 2

	var room_min_i = room_x + 2
	var room_max_i = room_x + room_width

	var room_min_j = room_y + 2
	var room_max_j = room_y + room_height

	for i in range(room_min_i, room_max_i + 1, 2):
		for j in range(room_min_j, room_max_j + 1, 2):
			# Add a floor
			var new_floor = Floor.instance()
			add_child(new_floor)
			new_floor.translate(Vector3(i, 1, j))

			var new_ceiling = Ceiling.instance()
			add_child(new_ceiling)
			new_ceiling.translate(Vector3(i, 1, j))

			var wall_type = Wall
			if Vector2(i, j) in room_area.open_doors:
				wall_type = DoorOpen
			elif Vector2(i, j) in room_area.door_walls:
				wall_type = DoorWall
			elif Vector2(i, j) in room_area.open_windows:
				pass
			elif Vector2(i, j) in room_area.close_windows:
				if randi() % 2 == 0:
					wall_type = WindowClose
				else:
					wall_type = WindowOpen

			if i == room_min_i and j % 2 == 0:
				create_wall(wall_type, Vector3(i - 1, 1, j), 90 * PI / 180)
			elif i == room_max_i and j % 2 == 0:
				create_wall(wall_type, Vector3(i + 1, 1, j), -90 * PI / 180)

			if j == room_min_j and i % 2 == 0:
				create_wall(wall_type, Vector3(i, 1, j - 1), 0)
			elif j == room_max_j and i % 2 == 0:
				create_wall(wall_type, Vector3(i, 1, j + 1), PI)


func create_wall(wall_type, offset, rotation):
#	var wall_type = Wall
#	if _door_counter_by_room < MAX_DOOR_BY_ROOM and randi() % 2 == 0:
#		_door_counter_by_room += 1
#		wall_type = DoorOpen
#	elif _window_counter_by_room < MAX_WINDOW_BY_ROOM and randi() % 2 == 0:
#		_window_counter_by_room += 1
#		wall_type = WindowClose

	var new_wall = wall_type.instance()
	add_child(new_wall)
	new_wall.translate(offset)
	new_wall.rotate(Vector3.UP, rotation)


#
# Part to generate 2d house map
#


func _generate_data(rng: RandomNumberGenerator) -> Array:
	var data := {}
	var rooms := []
	for _r in range(rooms_max):
		var room := _get_random_room(rng)
		if _intersects(rooms, room):
			continue

		_add_room(data, rooms, room)
		if rooms.size() > 1:
			var room_previous: Rect2 = rooms[-2]
			_add_connection(rng, data, room_previous, room)
	return data.keys()


func _get_random_room(rng: RandomNumberGenerator) -> Rect2:
	# var width := rng.randi_range(rooms_size.x, rooms_size.y)
	# var height := rng.randi_range(rooms_size.x, rooms_size.y)
	var x := rng.randi_range(0, level_size.x - 1)
	var y := rng.randi_range(0, level_size.y - 1)
	return Rect2(x, y, 1, 1)


func _add_room(data: Dictionary, rooms: Array, room: Rect2) -> void:
	rooms.push_back(room)
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			data[Vector2(x, y)] = null


func _add_connection(
	rng: RandomNumberGenerator, data: Dictionary, room1: Rect2, room2: Rect2
) -> void:
	var room_center1 := (room1.position + room1.end) / 2
	var room_center2 := (room2.position + room2.end) / 2
	if rng.randi_range(0, 1) == 0:
		_add_corridor(data, room_center1.x, room_center2.x, room_center1.y, Vector2.AXIS_X)
		_add_corridor(data, room_center1.y, room_center2.y, room_center2.x, Vector2.AXIS_Y)
	else:
		_add_corridor(data, room_center1.y, room_center2.y, room_center1.x, Vector2.AXIS_Y)
		_add_corridor(data, room_center1.x, room_center2.x, room_center2.y, Vector2.AXIS_X)


func _add_corridor(data: Dictionary, start: int, end: int, constant: int, axis: int) -> void:
	for t in range(min(start, end), max(start, end) + 1):
		var point := Vector2.ZERO
		match axis:
			Vector2.AXIS_X:
				point = Vector2(t, constant)
			Vector2.AXIS_Y:
				point = Vector2(constant, t)
		data[point] = null


func _intersects(rooms: Array, room: Rect2) -> bool:
	var out := false
	for room_other in rooms:
		if room.intersects(room_other):
			out = true
			break
	return out
