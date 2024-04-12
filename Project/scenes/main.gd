extends Control

var animation_library: AnimationLibrary = load("res://globals/animation_library.tres")
enum {EMPTY,AIMING,THROWING}
var right_hand_tex = [load("res://ui/right_hand_empty.png"),load("res://ui/right_hand_aim.png"),load("res://ui/right_hand_throw.png")]
var cursor_scrolling = false
enum items {COIN_BAG,CROWN,GEMS}
var item_icons = [load("res://entities/items/coin_bag/coin_bag_icon.png"),load("res://entities/items/crown/crown_icon.png"),load("res://entities/items/gems/gem_triple_icon.png")]
var shopkeep_tex = {
	-2: load("res://entities/shopkeep/shopkeep_ll.png"),
	-1: load("res://entities/shopkeep/shopkeep_l.png"),
	0: load("res://entities/shopkeep/shopkeep.png"),
	1: load("res://entities/shopkeep/shopkeep_r.png"),
	2: load("res://entities/shopkeep/shopkeep_rr.png"),
}

var cursor_shelf = 0
var item_list = [items.COIN_BAG,items.CROWN,items.GEMS]
var list_crossed = item_list
var status = AIMING

var shopkeep_dir = 0
var distraction = .5

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	for i in $LeftHand/ItemList.get_child_count():
		$LeftHand/ItemList.get_child(i).texture = item_icons[item_list[i]]

func _process(delta):
	#Input
	if Input.is_action_just_pressed('action'):
		if status == AIMING:
			status = THROWING
	if Input.is_action_just_released('action'):
		if status == THROWING:
			status = EMPTY
			$Cursor.hide()
			$Ball.position = $RightHand.position+Vector2(96,96)
			animation_library.get_animation('throw').track_set_key_value(0,0,$Ball.position)
			animation_library.get_animation('throw').track_set_key_value(0,1,$Cursor.position)
			var opposite_x = $Cursor.position.x - (896-$Cursor.position.x)
			animation_library.get_animation('throw').track_set_key_value(0,2,Vector2(opposite_x,600))
			$Ball.show()
			$Ball/AnimationPlayer.play('throw')
	
	if Input.is_action_just_pressed("ui_left"):
		if shopkeep_dir > -2:
			shopkeep_dir -= 1
	if Input.is_action_just_pressed("ui_right"):
		if shopkeep_dir < 2:
			shopkeep_dir += 1
	$Shopkeep.texture = shopkeep_tex.get(shopkeep_dir)
	
	
	#Status
	$RightHand.texture = right_hand_tex[status]
	if status == AIMING:
		$Cursor.position.x = get_global_mouse_position().x
		$RightHand.position.x = 810 - get_global_mouse_position().x / 300
	if status == THROWING:
		if !cursor_scrolling: scroll_cursor()
	#Distraction
	var distraction_position = $DistractionBar.size.x * distraction
	$DistractionBar/FillMask.size.x = distraction_position
	$DistractionBar/Icon.position.x = distraction_position - 19
	if distraction >= 0: distraction -= .01 * delta
	else:
		get_tree().change_scene_to_file("res://scenes/game_over/game_over.tscn")

func scroll_cursor():
	if $Cursor/Timer.is_stopped():
		$Cursor/Timer.start()

func _on_cursor_timer_timeout():
	if status == THROWING:
		$Cursor.position.y = $ShelfMarkers.get_child(cursor_shelf).position.y
		$RightHand.position.y = 384 - cursor_shelf*2
		if cursor_shelf < 2: cursor_shelf += 1
		else: cursor_shelf = 0
		scroll_cursor()

func _on_ball_peak():
	for i in $Ball/Area2D.get_overlapping_areas():
		if i.is_in_group('item_area'):
			print("ding")
			var item_id = items.get(i.get_parent().animation.to_upper())
			if item_list.find(item_id) != -1:
				print("scrawling")
				list_crossed.pop_at(list_crossed.find(item_id))
				$LeftHand/ItemList.get_child(item_id).get_node("Slash").show()
				if !list_crossed.size():
					get_tree().change_scene_to_file("res://scenes/game_over/game_over.tscn")
			i.get_parent().play()
			break

func _on_ball_animation_finished(anim_name):
	if anim_name == 'throw':
		status = AIMING
		cursor_shelf = 0
		$Cursor.position.y = $ShelfMarkers.get_child(cursor_shelf).position.y
		$Cursor.show()
