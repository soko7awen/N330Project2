extends AnimatedSprite2D
@export var used: bool = false

func _ready():
	$Area2D.get_node(animation.to_pascal_case()).disabled = false
