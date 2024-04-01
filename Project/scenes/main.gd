extends Node2D

var aim_tex = load("res://ui/right_hand_aim.png")
var throw_tex = load("res://ui/right_hand_throw.png")
var empty_tex = load("res://ui/right_hand_empty.png")

enum STATUSES {AIMING,THROWING,EMPTY}
var status = STATUSES.AIMING

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta):
	$Cursor.position.x = get_global_mouse_position().x
	if Input.is_action_just_pressed("action"):
		status = STATUSES.THROWING
		$RightHand.texture = throw_tex
	if Input.is_action_just_released("action"):
		status = STATUSES.EMPTY
		$RightHand.texture = empty_tex
		$Ball.show()
		$Ball.position = Vector2(get_global_mouse_position().x,180)
