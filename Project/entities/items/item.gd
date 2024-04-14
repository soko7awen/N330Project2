extends AnimatedSprite2D

func _ready():
	$Area2D.get_node(animation.to_pascal_case()).disabled = false

func _on_animation_finished():
	queue_free()
