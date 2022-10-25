# TODO : consider keyboard like a joypad

extends Node

var _joypad_count := 0


func add_player() -> int:
	var idx = _joypad_count

	# Duplicate input map action with each new player
	for action in [
		"move_forward",
		"move_back",
		"move_left",
		"move_right",
		"jump",
		"sprint",
		"lookup",
		"lookdown",
		"lookleft",
		"lookright",
		"crounch",
		"shoot",
		"zoom",
		"reload"
	]:
		var action_name = action + str(idx)

		# Create a new action for the new player
		InputMap.add_action(action_name)

		# For each joypad motion action
		for event in InputMap.get_action_list(action):
			if idx == 0 or event is InputEventJoypadMotion or event is InputEventJoypadButton:
				# InputEvent is a reference, we need to duplicate it
				var new_event = event.duplicate()

				# DEBUG : to use keyboard & controller
				if (
					idx == 0
					and (event is InputEventJoypadMotion or event is InputEventJoypadButton)
				):
					continue
				var device_num = idx
				if (
					idx == 1
					and (event is InputEventJoypadMotion or event is InputEventJoypadButton)
				):
					device_num = 0

				# Assign the new device linked to the player
				new_event.set_device(device_num)
				# Add the new event to the new action
				InputMap.action_add_event(action_name, new_event)

	_joypad_count += 1

	return idx
