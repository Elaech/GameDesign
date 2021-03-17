extends CanvasLayer

func _process(delta):
	self.transform = get_parent().transform
