extends KinematicBody2D


signal enemy_death(enemy)
export var enemy_id = 0
export var fire_rate = 3
export var fire_duration = 3
export var is_moving = false
export var move_speed = 100
export var moving_duration = 2
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
	$FireTimer.start(fire_rate)
	$AnimatedSprite.animation = "Idle"
	initial_position = global_position

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
