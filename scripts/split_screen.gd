extends Node

var PlayerScreen = preload("res://scenes/psx_layer.tscn")

var _player_count := 2


func _ready() -> void:
	jm.manager().set_num_split_screen_viewports(_player_count)

	for idx in range(_player_count):
		var new_player = PlayerScreen.instance()
		jm.manager().set_player_camera(new_player, idx, "arena")

	Input.connect("joy_connection_changed", self, "_on_SplitScreen_joy_connection_changed")


func _process(_delta):
	if jm.manager().is_loading_scene():
		var progress = jm.manager().get_load_scene_progress()
		print(progress)
	elif !jm.manager().failed_loading_scene():
		pass


func _on_SplitScreen_joy_connection_changed(device: int, connected: bool):
	if connected:
		print("Device[", device, "] connected.")
	else:
		print("Device[", device, "] disconnected.")
