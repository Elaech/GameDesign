extends Label
#onready var Box = get_node("Label")

func _ready():
	self.set_text("You awaken in a strange place, the crash scrambled your circuits\nquite a bit, but you remember your basic functionalities . . .\nR - activate canon\nWASD - select firing direction\n123 - select cannon output power\n")
func _process(delta):
	pass
