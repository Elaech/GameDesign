extends TileMap

const SpikeHurtboxResource = preload("res://WorldObjects/SpikesHurtbox.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	for cell in get_used_cells():
		var spike = SpikeHurtboxResource.instance()
		spike.position = map_to_world(cell) + Vector2(4,4)
		self.add_child(spike)
