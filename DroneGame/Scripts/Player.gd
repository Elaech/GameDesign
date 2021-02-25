# Player.gd
extends KinematicBody2D

var FRICTION = 0.03
var GRAVITY = 80
var MAX_SPEED = 100
var CANNON_FORCE = 60
var next_cannon_timer_wait_time = 0.5
var cannon_switch_time = 1
var motion = Vector2.ZERO
var propulsion_direction = Vector2.UP
var cannon_active = false
const CANNONBALL_RESOURCE =preload("res://WorldObjects/Cannonball.tscn")
onready var cannon_timer = get_node("CannonTimer")
onready var cannon_switch_timer = get_node("CannonSwitchTimer")
onready var shooting_point = get_node("ShootingPoint")


func _ready():
	cannon_timer.start(next_cannon_timer_wait_time)


func _physics_process(delta):
	if Input.is_key_pressed(KEY_R) and cannon_switch_timer.is_stopped():
		if cannon_active:
			cannon_active = false
		else:
			cannon_active = true
		cannon_switch_timer.start(cannon_switch_time)
			
	if Input.is_key_pressed(KEY_A):
		propulsion_direction = Vector2.RIGHT
	elif Input.is_key_pressed(KEY_D):
		propulsion_direction = Vector2.LEFT
	elif Input.is_key_pressed(KEY_S):
		propulsion_direction = Vector2.UP
	elif Input.is_key_pressed(KEY_W):
		propulsion_direction= Vector2.DOWN
	motion.y += GRAVITY * delta
	motion.x = lerp(motion.x,0,FRICTION)
	motion.y = lerp(motion.y,0,FRICTION)
	motion = move_and_slide(motion)
	

func shoot_cannon():
	if cannon_active:
		shoot_cannonball()
		motion += adjust_direction_motion(propulsion_direction)
		motion.x = clamp(motion.x,-MAX_SPEED,MAX_SPEED)
		motion.y = clamp(motion.y,-MAX_SPEED,MAX_SPEED)

func adjust_direction_motion(direction):
	var end_motion = direction
	match direction:
		Vector2.DOWN:
			end_motion *= 0.5
		Vector2.UP:
			end_motion *= 1.25
	return end_motion * CANNON_FORCE
	
func shoot_cannonball():
	var cannonball_instance = CANNONBALL_RESOURCE.instance()
	cannonball_instance.direction = -propulsion_direction
	cannonball_instance.position = self.position - propulsion_direction * 3
	self.get_parent().add_child(cannonball_instance)
	
func _on_Timer_timeout():
	shoot_cannon()
	cannon_timer.start(next_cannon_timer_wait_time)


func _on_CannonSwitchTimer_timeout():
	cannon_switch_timer.stop()
