extends KinematicBody2D


onready var BULLET_SCENE = preload("res://WorldObjects/basicBullet.tscn")
var player = null



func _physics_process(delta):
	
	if player != null:
		pass
	

func _on_Area2D_body_entered(body):
	if body != self:
		player = body


func _on_Area2D_body_exited(body):
	player = null

func fire():
	var bullet = BULLET_SCENE.instance()
	bullet.position = get_global_position()
	bullet.player = player
	get_parent().add_child(bullet)
	$Timer.set_wait_time(1)

func _on_Timer_timeout():
	if player !=null:
		fire()
