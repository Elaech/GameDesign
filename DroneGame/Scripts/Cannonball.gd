extends Area2D

const CANNONBALL_SPEED = 40
var direction = Vector2.ZERO
var damage = 0
onready var sprite = get_node("Sprite")

func _process(delta):
	var motion = CANNONBALL_SPEED*direction
	set_position(get_position() + motion *delta)

func _on_VisibilityEnabler2D_screen_exited():
	queue_free()



func change_scale(scale_multi):
	self.scale = self.scale * scale_multi


func _on_Cannonball_body_entered(body):
	queue_free()
