extends Node
var player_movement = false
var state = {
	'node': null,
	'event': null,
	'level': 1
	}
var jester_score = 0

func _process(_delta):
	if state.event != null:
		if state.event == 'riddle_win':
			set_player_movement(false)
			jester_score += state.level
			$"../main/HUD/HBoxContainer/MarginContainer/TextureRect/SubViewport/Label".text = str(jester_score)
			var actionable = get_node('../main/'+state.node+"/Actionable")
			actionable.dialogue_start = "win"
			actionable.action()
			state_clear()
		elif state.event == 'riddle_lose':
			set_player_movement(false)
			jester_score -= state.level
			$"../main/HUD/HBoxContainer/MarginContainer/TextureRect/SubViewport/Label".text = str(jester_score)
			var actionable = get_node('../main/'+state.node+"/Actionable")
			actionable.dialogue_start = "lose"
			actionable.action()
			state_clear()
		elif state.event == 'boss_win_done':
			get_node('../main/'+state.node).queue_free()
			set_player_movement(true)
			state_clear()
		elif state.event == 'boss_lose_done':
			get_tree().quit()
			state_clear()
		else:
			if player_movement == true:
				set_player_movement(false)
				var minigame_node = load("res://menus/minigames/"+state.event+"/"+state.event+".tscn").instantiate()
				minigame_node.level = state.level
				minigame_node.caller = state.node
				$/root/main/CanvasLayer.add_child(minigame_node)
				minigame_node.ended.connect(_on_minigame_ended)
				state_clear()


func set_player_movement(value: bool):
	if value == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		await get_tree().create_timer(.1).timeout
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	player_movement = value
	
func _on_minigame_ended(node,caller,winlose,score):
	node.queue_free()
	jester_score += score
	$"../main/HUD/HBoxContainer/MarginContainer/TextureRect/SubViewport/Label".text = str(jester_score)
	var actionable = get_node('../main/'+caller+"/Actionable")
	actionable.dialogue_start = winlose
	actionable.action()
	
func state_clear():
	state.node = null
	state.event = null
	state.level = 1

func end_game():
	$"../main/CanvasLayer/"
	$"../main/CanvasLayer".add_child(load("res://menus/end/end_cutscene.tscn").instantiate())
