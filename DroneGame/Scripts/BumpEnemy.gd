extends KinematicBody2D

var damage = 100
var life = 100
var player_detected = false
onready var player = get_node("../Player")
onready var timer = get_node("DirectionTimer")
var direction_time = 0.25
var motion = Vector2.ZERO
var direction = Vector2.ZERO
var MAX_SPEED = 60
var SPEED = 40
var WANDER_SPEED = 2
var FRICTION = 0.03
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func _process(_delta):
	if player_detected:
		if timer.is_stopped():
			direction = (-self.position + player.position).normalized()
			timer.start(direction_time)
		motion += direction*SPEED
	motion.x += rng.randf_range(-1,1) * WANDER_SPEED
	motion.y += rng.randf_range(-1,1) * WANDER_SPEED
	motion.x = clamp(motion.x,-MAX_SPEED,MAX_SPEED)
	motion.y = clamp(motion.y,-MAX_SPEED,MAX_SPEED)
	motion.x = lerp(motion.x,0,FRICTION)
	motion.y = lerp(motion.y,0,FRICTION)
	motion = move_and_slide(motion)
		

func _on_Hurtbox_area_entered(area):
	if area.has_method("get_damage"):
		life = life - area.get_damage()
		if life <= 0:
			queue_free()

func get_damage():
	return damage


func _on_PlayerDetector_area_entered(_area):
	player_detected = true


func _on_DirectionTimer_timeout():
	timer.stop()
