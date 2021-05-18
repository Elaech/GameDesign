extends KinematicBody2D

onready var sprite = get_node("AnimatedSprite")
onready var BULLET_SCENE = preload("res://WorldObjects/basicBullet.tscn")
var player = null
var life = 125
export var enemy_id = 0
signal enemy_death(enemy)
var initial_position = null

func _ready():
	initial_position = global_position

func despawn(poz):
	visible = false
	global_position = poz
	
func respawn():
	global_position = initial_position
	visible = true

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
			emit_signal("enemy_death",self)
