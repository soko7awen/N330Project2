extends Node

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event.is_action_pressed("fullscreen"):
		if get_viewport().mode == Window.MODE_FULLSCREEN:
			get_viewport().mode = Window.MODE_MAXIMIZED
		else:
			get_viewport().mode = Window.MODE_FULLSCREEN
	if event.is_action_pressed("quit"):
		get_tree().quit()
