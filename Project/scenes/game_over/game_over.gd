extends Control
var main_scene = load("res://scenes/main/main.tscn")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var time_took = GameEndStats.end_time - GameEndStats.start_time
	if GameEndStats.items_grabbed == 3:
		$Bkg.texture = load("res://scenes/game_over/bkg_win.png")
		$MarginContainer/Text/Heading.text = "Successful Heist"
		$MarginContainer/Text/CountMsgContainer/Msg1.text = "Took "
		$MarginContainer/Text/CountMsgContainer/Count.text = str(int(time_took))
		$MarginContainer/Text/CountMsgContainer/Msg2.text = " Seconds"
	else:
		$MarginContainer/Text/CountMsgContainer/Count.text = str(GameEndStats.items_grabbed)

func _input(event):
	if event.is_action_pressed("action"):
		get_tree().change_scene_to_packed(main_scene)
