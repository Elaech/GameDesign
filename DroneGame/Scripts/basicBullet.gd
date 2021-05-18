extends Area2D

var move = Vector2.ZERO
var look_vec = Vector2.ZERO
var player = null
var speed = 2
var damage = 50
var initial_position = null
var time = 0.05

func despawn(poz):
	visible = false
	global_position = poz
	
func respawn():
	global_position = initial_position
	visible = true


func _ready():
	$CollisionShape2D.set_deferred("disabled",true)
	$Timer.start(time)
	initial_position = global_position
	look_vec = player.position - global_position
	
func _physics_process(delta):
	move = Vector2.ZERO
	
	move = move.move_toward(look_vec, delta)
	move = move.normalized()*speed
	position += move

func get_damage():
	return damage

func _on_Area2D_body_entered(body):
	queue_free()



func _on_Timer_timeout():
	$Timer.stop()
	$CollisionShape2D.set_deferred("disabled",false)
