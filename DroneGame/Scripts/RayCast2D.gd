extends RayCast2D

var is_casting := false setget set_is_casting
var width = float(10.0)

func _ready():
	set_physics_process(false)
	$Line2D.points[1] = Vector2.ZERO
	$Line2D2.points[1] = Vector2.ZERO
	$Hitbox/CollisionShape2D.shape = RectangleShape2D.new()
	$Hitbox/CollisionShape2D.disabled = true
	

func _physics_process(delta):
	$Line2D.width = width/2.0
	$Line2D2.width = width
	var cast_point := cast_to
	force_raycast_update()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
		$Line2D.points[1] = cast_point
		$Line2D2.points[1] = cast_point
		
	else:
		$Line2D.points[1] = Vector2(0,-1000)
		$Line2D2.points[1] = Vector2(0,-1000)
	$Hitbox/CollisionShape2D.position = Vector2(($Line2D.points[0].x+$Line2D.points[1].x)/2.0,($Line2D.points[0].y+$Line2D.points[1].y)/2.0)
	$Hitbox/CollisionShape2D.shape.extents = Vector2(width/2.0,abs($Line2D.points[0].y-$Line2D.points[1].y)/2.0)

func set_is_casting(cast: bool):
	is_casting = cast
	if is_casting:
		appear()
	else:
		disappear()
	set_physics_process(is_casting)

func appear():

	$Tween.stop_all()
	$Tween.interpolate_property($Line2D,"width",0.0,width/2.0,0.2)
	$Tween.interpolate_property($Line2D2,"width",0.0,width,0.2)
	$Hitbox/CollisionShape2D.disabled = false
	$Tween.start()
	
func disappear():
	$Tween.stop_all()
	$Hitbox/CollisionShape2D.disabled = true
	$Tween.interpolate_property($Line2D,"width",width/2.0,0.0,0.1)
	$Tween.interpolate_property($Line2D2,"width",width,0.0,0.1)
	$Tween.start()
