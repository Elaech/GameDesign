extends Node2D

onready var Portal = get_node("portal")


signal level_finished
onready var detection = get_node("PlayerInteraction")
var active= false


func _ready(): 
	detection.set_process(false)
	

func _on_portal_animation_finished():
	Portal.set_speed_scale(0.8)
	Portal.set_animation("Loop")
	detection.set_process(true)


func _on_PlayerInteraction_area_entered(area):
	emit_signal("level_finished")


func _on_PlayerDetection_area_entered(area):
	if !active:
		active = true
		Portal.set_speed_scale(0.4)
		Portal.set_animation("Form")
		
