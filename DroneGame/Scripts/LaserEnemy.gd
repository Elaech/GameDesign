extends KinematicBody2D


signal enemy_death(enemy)
export var enemy_id = 0
export var animation_speed = 1.0
export var initial_delay = 3.0
export var fire_rate = 3.0
export var fire_duration = 3.0
export var is_moving = false
export var width = 10.0
var initial_position = null
var life = 200
var damage = 300

func despawn(poz):
	visible = false
	global_position = poz
	
func respawn():
	global_position = initial_position
	visible = true


func _ready():
	$FireTimer.start(initial_delay)
	$AnimatedSprite.animation = "Idle"
	$AnimatedSprite.speed_scale = animation_speed
	initial_position = global_position
	$RayCast2D.width = self.width

func _on_FireTimer_timeout():
	$FireTimer.stop()
	$AnimatedSprite.animation = "Open"

func _on_FireDuration_timeout():
	$FireDuration.stop()
	$RayCast2D.set_is_casting(false)
	$AnimatedSprite.animation = "Close"


func _on_AnimatedSprite_animation_finished():
	match $AnimatedSprite.animation:
		"Open":
			$RayCast2D.set_is_casting(true)
			$FireDuration.start(fire_duration)
			$AnimatedSprite.animation = "Attack"
		"Close":
			$FireTimer.start(fire_rate)
			$AnimatedSprite.animation = "Idle"
		_:
			pass

func get_damage():
	return damage

func _on_Hurtbox_area_entered(area):
	if area.has_method("get_damage"):
		life = life - area.get_damage()
		if life <= 0:
			emit_signal("enemy_death",self)
