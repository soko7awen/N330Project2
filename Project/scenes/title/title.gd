extends Control
var main_scene = load("res://scenes/main/main.tscn")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_begin_pressed():
	get_tree().change_scene_to_packed(main_scene)
