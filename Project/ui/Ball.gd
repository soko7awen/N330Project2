extends Sprite2D

@export var peak = false
signal peak_now

func _process(_delta):
	if peak == true:
		peak_now.emit()
		peak = false
