extends Node

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(load("res://scenes/pause_menu/pause_menu.tscn").instantiate())

func _input(event):
	if event.is_action_pressed("fullscreen"):
		if get_viewport().mode == Window.MODE_FULLSCREEN:
			get_viewport().mode = Window.MODE_MAXIMIZED
		else:
			get_viewport().mode = Window.MODE_FULLSCREEN
	if event.is_action_pressed("quit"):
		get_tree().quit()

func pause():
	$PauseMenu.pause()

#func unpause():
#	get_tree().paused = false
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#	$PauseMenu.hide()
