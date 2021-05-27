extends KinematicBody2D

signal boss_death(boss)

var disk_rotation_speed
var disk_rev_rotation_speed = -0.5
var disk_norm_rotation_speed = 0.1
var spin_time = 3
var spin_back_time = 2
var speed_multi = 1

var life = 10000

func _ready():
	$RotationTimer.start(spin_time)
	disk_rotation_speed = disk_norm_rotation_speed


func _process(delta):
	$Disk.rotate(disk_rotation_speed)



func _on_RotationTimer_timeout():
	$RotationTimer.stop()
	if disk_rotation_speed == disk_norm_rotation_speed:
		disk_rotation_speed = disk_rev_rotation_speed * speed_multi
		$RotationTimer.start(spin_back_time)
	else:
		disk_rotation_speed = disk_norm_rotation_speed * speed_multi
		$RotationTimer.start(spin_time)
	

func get_damage():
	return 999999


func _on_Hurtbox_area_entered(area):
	if area.has_method("get_damage"):
		life = life - area.get_damage()
		if life <= 0:
			emit_signal("boss_death",self)
