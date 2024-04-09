extends Node2D

var aim_tex = load("res://ui/right_hand_aim.png")
var throw_tex = load("res://ui/right_hand_throw.png")
var empty_tex = load("res://ui/right_hand_empty.png")

enum STATUSES {AIMING,THROWING,EMPTY}
var status = STATUSES.AIMING
var cursor_scrolling = false
var cursor_shelf = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta):
	if Input.is_action_just_pressed("action"):
		if status == STATUSES.AIMING:
			status = STATUSES.THROWING
			$RightHand.texture = throw_tex
	if Input.is_action_just_released("action"):
		status = STATUSES.EMPTY
		$RightHand.texture = empty_tex
		#later
		$Ball.show()
		$Ball.position = $Cursor.position

	if status == STATUSES.AIMING:
		$Cursor.position.x = get_global_mouse_position().x
	if status == STATUSES.THROWING:
		if !cursor_scrolling: scroll_cursor()

func scroll_cursor():
	if $Cursor/Timer.is_stopped():
		$Cursor/Timer.start()

func _on_cursor_timer_timeout():
	if status == STATUSES.THROWING:
		$Cursor.position.y = $ShelfMarkers.get_child(cursor_shelf).position.y
		if cursor_shelf < 2: cursor_shelf += 1
		else: cursor_shelf = 0
		scroll_cursor()
