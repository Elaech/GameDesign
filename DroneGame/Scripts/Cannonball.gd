extends Area2D

const CANNONBALL_SPEED = 40
var direction = Vector2.ZERO


func _process(delta):
	var motion = CANNONBALL_SPEED*direction
	set_position(get_position() + motion *delta)

func _on_VisibilityEnabler2D_screen_exited():
	queue_free()
