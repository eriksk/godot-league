extends Spatial

class_name Wheel

onready var ground_ray: RayCast = $GroundRay

export var radius: float = 0.5
export var grounded: bool = false

onready var model:Spatial = $wheel

func _ready():
	ground_ray.cast_to = Vector3.DOWN * radius
#	ground_ray.debug_shape_thickness = 10

func rotate_lateral(radians):
	var rotation = model.rotation
	rotation.x += radians
	model.rotation = rotation
	
func steer(radians):
	var rotation = model.rotation
	rotation.y = radians
	model.rotation = rotation

func _process(_delta):
	grounded = ground_ray.is_colliding()
