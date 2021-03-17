extends Control


onready var health_bar = get_node("Over")
onready var under_health_bar = get_node("Under")
onready var tween = get_node("Tween")
var interpolation_finished = true

func update_health(health):
	health_bar.value = health
	tween.interpolate_property(under_health_bar,
	"value",under_health_bar.value,health,0.5,Tween.TRANS_SINE,Tween.EASE_IN_OUT,0)
	interpolation_finished = false
	tween.start()
	
func update_max_health(max_health):
	health_bar.max_value = max_health
	under_health_bar.max_value = max_health


func destroy():
	queue_free()
