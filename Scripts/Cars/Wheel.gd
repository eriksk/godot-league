extends Spatial

class_name Wheel

onready var ground_ray: RayCast = $GroundRay

export var radius: float = 0.5
export var grounded: bool = false

onready var model:Spatial = $wheel

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
