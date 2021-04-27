extends KinematicBody2D

onready var sprite = get_node("AnimatedSprite")
onready var BULLET_SCENE = preload("res://WorldObjects/basicBullet.tscn")
var player = null
var life = 125
export var tower_number = 0
signal death_occured(tower_number)


func _physics_process(delta):
	
	if player != null:
		pass
	

func _on_Area2D_body_entered(body):
	if body != self:
		player = body


func _on_Area2D_body_exited(body):
	player = null

func fire():
	sprite.play("Attack")
	var bullet = BULLET_SCENE.instance()
	bullet.position = get_global_position()
	bullet.player = player
	get_parent().add_child(bullet)
	$Timer.set_wait_time(1)

func _on_Timer_timeout():
	if player !=null:
		fire()
	else :
		sprite.play("Idle")
func _on_Hurtbox_area_entered(area):
	if area.has_method("get_damage"):
		life = life - area.get_damage()
		print(life)
		if life <= 0:
			sprite.play("Death")
			var t = Timer.new()
			t.set_wait_time(0.6)
			t.set_one_shot(true)
			self.add_child(t)
			t.start()
			yield(t, "timeout")
			emit_signal("death_occured",self)
			queue_free()
