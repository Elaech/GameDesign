extends KinematicBody2D


export var enemy_id = 0
var make_noise = true
signal enemy_death(enemy)
var damage = 100
var life = 100
var player_detected = false
var player = null
onready var timer = get_node("DirectionTimer")
onready var sprite = get_node("AnimatedSprite")
var direction_time = 0.25
var motion = Vector2.ZERO
var direction = Vector2.ZERO
var MAX_SPEED = 60
var SPEED = 40
var WANDER_SPEED = 2
var BUMP_SPEED = 4
var FRICTION = 0.03
var rng = RandomNumberGenerator.new()
var initial_position = null
func _ready():
	rng.randomize()
	initial_position = global_position
	
func heal():
	life = 100

func _process(_delta):
	if player_detected and player!=null:
		if timer.is_stopped():
			direction = (-self.position + player.position).normalized()
			timer.start(direction_time)
		motion += direction*SPEED
		motion.x += rng.randf_range(-1,1) * BUMP_SPEED
		motion.y += rng.randf_range(-1,1) * BUMP_SPEED
		adapt_sprite()
	elif make_noise:
		motion.x += rng.randf_range(-1,1) * WANDER_SPEED
		motion.y += rng.randf_range(-1,1) * WANDER_SPEED
	
	motion.x = clamp(motion.x,-MAX_SPEED,MAX_SPEED)
	motion.y = clamp(motion.y,-MAX_SPEED,MAX_SPEED)
	motion.x = lerp(motion.x,0,FRICTION)
	motion.y = lerp(motion.y,0,FRICTION)
	motion = move_and_slide(motion)
		
func despawn(poz):
	visible = false
	global_position = poz
	
func respawn():
	global_position = initial_position
	visible = true
	

func adapt_sprite():
	if direction.x > 0.0:
		sprite.flip_h = false
	elif direction.x < 0.0:
		sprite.flip_h = true

func _on_Hurtbox_area_entered(area):
	if area.has_method("get_damage"):
		life = life - area.get_damage()
		if life <= 0:
			emit_signal("enemy_death",self)

func get_damage():
	return damage


func _on_PlayerDetector_area_entered(area):
	player = area.get_parent()
	player_detected = true


func _on_DirectionTimer_timeout():
	timer.stop()


func _on_PlayerDetector_area_exited(area):
	player_detected = false
