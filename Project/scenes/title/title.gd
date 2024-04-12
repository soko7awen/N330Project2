extends Control
var main_scene = load("res://scenes/main.tscn")

func _on_begin_pressed():
	get_tree().change_scene_to_packed(main_scene)
