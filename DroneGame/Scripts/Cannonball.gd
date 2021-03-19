extends Area2D

var cannonball_speed = 40
var direction = Vector2.ZERO
var damage = 0
onready var sprite = get_node("Sprite")
onready var collision = get_node("CollisionShape2D")

func _process(delta):
	var motion = cannonball_speed*direction
	set_position(get_position() + motion *delta)

func _on_VisibilityEnabler2D_screen_exited():
	queue_free()



func change_scale(scale_multi):
	self.scale = self.scale * scale_multi


func _on_Cannonball_body_entered(_body):
	queue_free()


func change_look(index):
	match direction:
		Vector2.UP:
			sprite.rotation_degrees = 270
		Vector2.DOWN:
			sprite.rotation_degrees = 90
		Vector2.LEFT:
			sprite.rotation_degrees = 180
		Vector2.RIGHT:
			sprite.rotation_degrees = 0
		
		
	match index:
		1:
			sprite.frame = 0
			self.scale = Vector2(0.7,0.7)
		2:
			sprite.frame = 1
			self.scale = Vector2(1.0,1.0)
		3:
			sprite.frame = 2
			self.scale = Vector2(1.2,1.2)


func _on_Hitbox_area_entered(_area):
	queue_free()

func get_damage():
	return damage
