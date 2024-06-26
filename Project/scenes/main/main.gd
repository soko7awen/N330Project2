extends Control

var animation_library: AnimationLibrary = load("res://globals/animation_library.tres")
enum {EMPTY,AIMING,THROWING}
var right_hand_tex = [load("res://ui/right_hand_empty.png"),load("res://ui/right_hand_aim.png"),load("res://ui/right_hand_throw.png")]
var cursor_scrolling = false
var shopkeep_icons = {
	"normal": load("res://ui/distractionbar_icon.png"),
	"sus": load("res://ui/distractionbar_icon_sus.png")}
enum items {COIN_BAG,CROWN,GEMS,POTION}
var item_icons = [load("res://ui/icon_coin_bag.png"),load("res://ui/icon_crown.png"),load("res://ui/icon_gems.png"),load("res://ui/icon_potion.png")]
enum distractions {BOTTLE,FIRECRACKERS,JACK_IN_THE_BOX}
var shopkeep_tex = {
	-2: load("res://entities/shopkeep/shopkeep_ll.png"),
	-1: load("res://entities/shopkeep/shopkeep_l.png"),
	0: load("res://entities/shopkeep/shopkeep.png"),
	1: load("res://entities/shopkeep/shopkeep_r.png"),
	2: load("res://entities/shopkeep/shopkeep_rr.png")}
var shopkeep_tex_sus = {
	-2: load("res://entities/shopkeep/shopkeep_ll.png"),
	-1: load("res://entities/shopkeep/shopkeep_l.png"),
	0: load("res://entities/shopkeep/shopkeep_sus.png"),
	1: load("res://entities/shopkeep/shopkeep_r.png"),
	2: load("res://entities/shopkeep/shopkeep_rr.png")}

var started = false
var cursor_shelf = 0
var item_list = [items.COIN_BAG,items.CROWN,items.GEMS]
var list_crossed
var status = AIMING
var mouse_moved = false

var shopkeep_dir = 0
var distraction = .7

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	for i in $Distractions.get_children():
		i.animation = distractions.keys()[randi_range(0,2)].to_snake_case()
	for i in $Items.get_children():
		i.animation = items.keys()[randi_range(0,3)].to_snake_case()
	for i in item_list.size():
		var rand_item_val = randi_range(0,3)
		item_list[i] = rand_item_val
		var rand_item_found = false
		for j in $Items.get_children():
			if !j.is_in_group('required_items') and j.animation == items.keys()[rand_item_val].to_snake_case():
				j.add_to_group('required_items')
				rand_item_found = true
				break
		if !rand_item_found:
			var rand_item_place = randi_range(0,$Items.get_child_count()-1)
			var rand_item = $Items.get_child(rand_item_place)
			while rand_item.get_groups().has('required_items'):
				rand_item_place = randi_range(0,$Items.get_child_count()-1)
				rand_item = $Items.get_child(rand_item_place)
			rand_item.animation = items.keys()[rand_item_val].to_snake_case()
			rand_item.add_to_group('required_items')
	list_crossed = item_list.duplicate(false)
	for i in $LeftHand/ItemList.get_child_count():
		$LeftHand/ItemList.get_child(i).texture = item_icons[item_list[i]]
	if GameEndStats.first_game:
		$FirstGameUI.show()

func _process(delta):
	#Input
	if Input.is_action_just_pressed('action'):
		if status == AIMING:
			status = THROWING
			if GameEndStats.first_game:
				$FirstGameUI/AnimationPlayer.play('click')
	if Input.is_action_just_released('action'):
		if status == THROWING:
			status = EMPTY
			$Cursor.hide()
			$Ball.position = $RightHand.position+Vector2(96,96)
			$Ball/AnimationPlayer.play('RESET')
			animation_library.get_animation('throw').track_set_key_value(0,0,$Ball.position)
			animation_library.get_animation('throw').track_set_key_value(0,1,$Cursor.position)
			var opposite_x = $Cursor.position.x - (896-$Cursor.position.x)
			animation_library.get_animation('throw').track_set_key_value(0,2,Vector2(opposite_x,600))
			$Ball.show()
			$Shopkeep/PositionTimer.stop()
			$Shopkeep/DistractionTimer.stop()
			$Ball/AnimationPlayer.play('throw')
	
	if distraction > .3:
		$Shopkeep.texture = shopkeep_tex.get(shopkeep_dir)
	else:
		$Shopkeep.texture = shopkeep_tex_sus.get(shopkeep_dir)
		$BkgMusic.pitch_scale = 1.9
	#Status
	$RightHand.texture = right_hand_tex[status]
	if status == AIMING:
		$Cursor.position.x = get_global_mouse_position().x
		$RightHand.position.x = 810 - get_global_mouse_position().x / 300
	if status == THROWING:
		if !cursor_scrolling: scroll_cursor()
	if started:
		if GameEndStats.first_game:
			$FirstGameUI.hide()
		#Distraction
		var distraction_position = $DistractionBar.size.x * distraction
		$DistractionBar/FillMask.size.x = distraction_position
		$DistractionBar/Icon.position.x = distraction_position - 19
		if distraction >= 0: distraction -= .025 * delta
		else:
			end_game(list_crossed)
		if distraction > .3:
			$DistractionBar/Icon.texture = shopkeep_icons.normal
		else:
			$DistractionBar/Icon.texture = shopkeep_icons.sus
			$Shopkeep/PositionTimer.wait_time = 1

func scroll_cursor():
	if $Cursor/Timer.is_stopped():
		$Cursor/Timer.start()

func _on_cursor_timer_timeout():
	if status == THROWING:
		if started:
			$Cursor.position.y = $ShelfMarkers.get_child(cursor_shelf).position.y
		else:
			$Cursor.position.y = $TitleMarkers.get_child(cursor_shelf).global_position.y
		$RightHand.position.y = 384 - cursor_shelf*2
		if cursor_shelf < 2: cursor_shelf += 1
		else: cursor_shelf = 0
		scroll_cursor()

func _on_ball_peak():
	if started:
		$Ball.z_index = 1
		for i in $Ball/Area2D.get_overlapping_areas():
			if i.is_in_group('pause_area'):
				WindowControls.pause()
			else:
				if i.is_in_group('item_area'):
					print("ding")
					$SFX/Ding.play()
					var i_dir_clamped = clampi(i.get_parent().global_position.x - $Shopkeep.global_position.x,-1,1)
					var shopkeep_dir_clamped = clampi(shopkeep_dir,-1,1)
					var item_id = items.get(i.get_parent().animation.to_upper())
					i.get_parent().play()
					await get_tree().create_timer(1).timeout
					if !$Shopkeep/DistractionTimer.time_left:
						shopkeep_dir = i_dir_clamped
					distraction = clamp(distraction-.1,0,1)
					if i_dir_clamped != shopkeep_dir_clamped:
						print(list_crossed)
						print(item_id)
						if list_crossed.find(item_id) != -1:
							print("scrawling")
							$SFX/Scrawling.play()
							list_crossed.pop_at(list_crossed.find(item_id))
							$LeftHand/ItemList.get_child(item_list.find(item_id)).get_node("Slash").show()
							if !list_crossed.size():
								end_game(list_crossed)
					else:
						end_game(list_crossed)
					break
				elif i.is_in_group('distraction_area'):
					if i.get_parent().used == false:
						i.get_parent().used = true
						var i_dir_clamped = clampi(i.get_parent().global_position.x - $Shopkeep.global_position.x,-1,1)
						print("dong")
						i.get_parent().play()
						i.get_parent().get_node("SFX").get_node(i.get_parent().animation.to_pascal_case()).play()
						$Shopkeep/PositionTimer.set_paused(true)
						$Shopkeep/DistractionTimer.start()
						shopkeep_dir = clampi(i_dir_clamped,-1,1)*2
						distraction = clamp(distraction+.4,0,1)
				distraction = clamp(distraction-.1,0,1)
	else:
		for i in $Ball/Area2D.get_overlapping_areas():
			if i.is_in_group('begin_area'):
				print("starting")
				$BkgMusic.play()
				started = true
				$Title.hide()
				$DistractionBar.show()
				$Shopkeep/PositionTimer.start()
				GameEndStats.start_time = Time.get_unix_time_from_system()

func _on_ball_animation_finished(_anim_name):
	if $Shopkeep/DistractionTimer.paused:
		$Shopkeep/DistractionTimer.set_paused(false)
	else:
		if started:
			$Shopkeep/PositionTimer.start()
	status = AIMING
	cursor_shelf = 0
	if started:
		$Cursor.position.y = $ShelfMarkers.get_child(cursor_shelf).position.y
	else:
		$Cursor.position.y = $TitleMarkers.get_child(cursor_shelf).global_position.y
	$Cursor.show()

func _on_shopkeep_position_timer_timeout():
	shopkeep_dir = clampi(shopkeep_dir+randi_range(-1,1),-2,2)
	$Shopkeep/PositionTimer.start()

func _on_shopkeep_distraction_timer_timeout():
	$Shopkeep/PositionTimer.set_paused(false)
	
func end_game(items_crossed):
	GameEndStats.item_list = item_list
	GameEndStats.items_crossed = items_crossed
	GameEndStats.end_time = Time.get_unix_time_from_system()
	get_tree().change_scene_to_file("res://scenes/game_over/game_over.tscn")

func _on_first_game_ui_timeout():
	$FirstGameUI/AnimationPlayer.play('click')
