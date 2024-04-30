extends Control
var main_scene = load("res://scenes/main/main.tscn")
var item_stills = [load("res://entities/items/coin_bag/coin_bag_still.png"),load("res://entities/items/crown/crown_still.png"),load("res://entities/items/gems/gem_triple_still.png"),load("res://entities/items/potion/potion_still.png")]

func _ready():
	GameEndStats.first_game = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var time_took = GameEndStats.end_time - GameEndStats.start_time
	print(GameEndStats.items_crossed.size())
	if GameEndStats.items_crossed.size() == 0:
		$Bkg.texture = load("res://scenes/game_over/bkg_win.png")
		$MarginContainer/Text/Heading.text = "Successful Heist"
		$MarginContainer/Text/CountMsgContainer/Msg1.text = "Took "
		$MarginContainer/Text/CountMsgContainer/Count.text = str(int(time_took))
		$MarginContainer/Text/CountMsgContainer/Msg2.text = " Seconds"
		for i in $Items.get_children().size():
			$Items.get_child(i).texture = item_stills[GameEndStats.item_list[i]]
		$Items.show()
	else:
		$MarginContainer/Text/CountMsgContainer/Count.text = str(GameEndStats.item_list.size()-GameEndStats.items_crossed.size())
		if GameEndStats.items_crossed.size() == 1:
			$MarginContainer/Text/CountMsgContainer/Msg2.text = " Item"

func _input(event):
	if event.is_action_pressed("action"):
		get_tree().change_scene_to_packed(main_scene)
