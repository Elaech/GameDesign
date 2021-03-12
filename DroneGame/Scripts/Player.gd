# Player.gd
extends KinematicBody2D

var LIFE = 5
var FRICTION = 0.03
var GRAVITY = 80
var MAX_SPEED = 100
var CANNON_FORCE = 60
var hurtbox_disable_time = 0.3
var next_cannon_timer_wait_time = 0.5
var cannon_switch_time = 1
var up_motion_multi = 1.25
var down_motion_multi = 0.5
var left_motion_multi = 1.25
var right_motion_multi = 1.25
var motion = Vector2.ZERO
var propulsion_direction = Vector2.UP
var cannon_active = false
var cannon_damage = 10
var cannon_mode = 2
var cannonball_speed = 80
const CANNONBALL_RESOURCE =preload("res://WorldObjects/Cannonball.tscn")
onready var cannon_timer = get_node("CannonTimer")
onready var cannon_switch_timer = get_node("CannonSwitchTimer")
onready var shooting_point = get_node("ShootingPoint")
onready var player_sprite = get_node("Sprite")
onready var hurtbox_timer = get_node("Hurtbox/HurtboxTimer")
onready var camera=  get_node("Camera2D")
onready var hurtbox_collision =  get_node("Hurtbox/CollisionShape2D")
onready var hurtbox = get_node("Hurtbox")
func _ready():
	cannon_timer.start(next_cannon_timer_wait_time)


func _physics_process(delta):
	if Input.is_key_pressed(KEY_R) and cannon_switch_timer.is_stopped():
		if cannon_active:
			cannon_active = false
			GRAVITY = 80
			MAX_SPEED = 180
		else:
			cannon_active = true
			load_cannon(cannon_mode)
		cannon_switch_timer.start(cannon_switch_time)
			
	check_change_direction()
	check_change_cannonmode()
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
			end_motion *= down_motion_multi
		Vector2.UP:
			end_motion *= up_motion_multi
		Vector2.LEFT:
			end_motion *= left_motion_multi
		Vector2.RIGHT:
			end_motion *= right_motion_multi
	return end_motion * CANNON_FORCE
	
func shoot_cannonball():
	var cannonball_instance = CANNONBALL_RESOURCE.instance()
	cannonball_instance.direction = -propulsion_direction
	cannonball_instance.damage =  cannon_damage
	cannonball_instance.cannonball_speed = cannonball_speed
	cannonball_instance.position = self.position - propulsion_direction * 3
	self.get_parent().add_child(cannonball_instance)
	cannonball_instance.change_look(cannon_mode)
	
	
func _on_Timer_timeout():
	shoot_cannon()
	cannon_timer.start(next_cannon_timer_wait_time)


func _on_CannonSwitchTimer_timeout():
	cannon_switch_timer.stop()

func check_change_direction():
	if Input.is_key_pressed(KEY_A):
		player_watches(Vector2.RIGHT)
		propulsion_direction = Vector2.RIGHT
	elif Input.is_key_pressed(KEY_D):
		player_watches(Vector2.LEFT)
		propulsion_direction = Vector2.LEFT
	elif Input.is_key_pressed(KEY_S):
		player_watches(Vector2.UP)
		propulsion_direction = Vector2.UP
	elif Input.is_key_pressed(KEY_W):
		player_watches(Vector2.DOWN)
		propulsion_direction= Vector2.DOWN

func check_change_cannonmode():
	if Input.is_key_pressed(KEY_1):
		if cannon_active:
			load_cannon(1)
		else:
			cannon_mode = 1
	elif Input.is_key_pressed(KEY_2):
		if cannon_active:
			load_cannon(2)
		else:
			cannon_mode = 2
	elif Input.is_key_pressed(KEY_3):
		if cannon_active:
			load_cannon(3)
		else:
			cannon_mode = 3

func load_cannon(index):
	if index == 1:
		MAX_SPEED = 40
		CANNON_FORCE = 20
		GRAVITY = 40
		next_cannon_timer_wait_time = 0.3
		cannon_damage = 3
		up_motion_multi = 1
		down_motion_multi = 0.4
		left_motion_multi = 1.5
		right_motion_multi = 1.5
		cannon_switch_time = 0.2
		cannon_mode = 1
		cannonball_speed = 60
	elif index == 2:
		MAX_SPEED = 180
		CANNON_FORCE = 80
		GRAVITY = 80
		next_cannon_timer_wait_time = 0.5
		cannon_damage = 10
		up_motion_multi = 1.25
		down_motion_multi = 0.5
		left_motion_multi = 1.25
		right_motion_multi = 1.25
		cannon_switch_time = 1
		cannon_mode = 2
		cannonball_speed = 80
	elif index ==3:
		MAX_SPEED = 250
		CANNON_FORCE = 200
		GRAVITY = 120
		next_cannon_timer_wait_time = 0.7
		cannon_damage = 30
		up_motion_multi = 1.25
		down_motion_multi = 0.5
		left_motion_multi = 1.25
		right_motion_multi = 1.25
		cannon_switch_time = 1
		cannon_mode = 3
		cannonball_speed = 120
		
func player_watches(direction):
	match direction:
		Vector2.DOWN:
			player_sprite.frame = 3
		Vector2.UP:
			player_sprite.frame = 2
		Vector2.LEFT:
			player_sprite.frame = 1
		Vector2.RIGHT:
			player_sprite.frame = 0
			
func take_damage(damage):
	if hurtbox_timer.is_stopped():
		LIFE =LIFE -damage
		print("Life is",LIFE)
		if LIFE <= 0:
			detach_camera()
			queue_free()
		else:
			set_deferred("hurtbox.monitorable", false)
			hurtbox_timer.start(hurtbox_disable_time)
			player_sprite.modulate = Color(1,1,1,0.5)



func detach_camera():
	self.remove_child(camera)
	get_parent().add_child(camera)
	camera.global_position = global_position

func _on_Hurtbox_area_entered(area):
	if area.has_method("get_damage"):
		take_damage(area.get_damage())


func _on_HurtboxTimer_timeout():
	hurtbox.monitorable = true
	hurtbox_timer.stop()
	player_sprite.modulate = Color(1,1,1,1)
	


func _on_Hurtbox_body_entered(body):
	if body.has_method("get_damage"):
		take_damage(body.get_damage())
