extends Node2D

onready var Portal = get_node("portal")


signal level_finished
var active= false
var can_be_entered = false


func _on_portal_animation_finished():
	Portal.set_speed_scale(0.8)
	Portal.set_animation("Loop")
	can_be_entered = true


func _on_PlayerInteraction_area_entered(area):
	if can_be_entered:
		emit_signal("level_finished")


func _on_PlayerDetection_area_entered(area):
	if !active:
		active = true
		Portal.set_speed_scale(0.4)
		Portal.set_animation("Form")
		
