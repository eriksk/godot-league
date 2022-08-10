extends RigidBody

onready var wheel_front_left: Wheel = $Car/BottomPlate/Wheel_Front_Left
onready var wheel_front_right: Wheel = $Car/BottomPlate/Wheel_Front_Right
onready var wheel_back_left: Wheel = $Car/BottomPlate/Wheel_Back_Left
onready var wheel_back_right: Wheel = $Car/BottomPlate/Wheel_Back_Right

export var max_steer_angle_degrees = 35.0
export var steer_speed = 1.0
export var acceleration: float = 1.0

var steering: float = 0.0
var input_steering: float = 0.0
var input_gas: float = 0.0

var wheels: Array = []

func _ready():
	wheels.append(wheel_front_left)
	wheels.append(wheel_front_right)
	wheels.append(wheel_back_left)
	wheels.append(wheel_back_right)

func integrate_steering(delta):
	steering = lerp(steering, input_steering, steer_speed * delta)
	steering = clamp(steering, -1.0, 1.0)

func rotate_wheels_lateral(radians):
	wheel_front_left.rotate_lateral(radians)
	wheel_front_right.rotate_lateral(radians)
	wheel_back_left.rotate_lateral(radians)
	wheel_back_right.rotate_lateral(radians)
	
func steer(degrees):
	wheel_front_left.steer(degrees)
	wheel_front_right.steer(degrees)

func _process(delta):
	input_steering = Input.get_axis("steer_right", "steer_left")
	input_gas =	Input.get_axis("reverse", "gas")
		
	integrate_steering(delta)
	steer(steering * deg2rad(max_steer_angle_degrees))

func _physics_process(_delta):
	add_torque(Vector3(0, steering * deg2rad(max_steer_angle_degrees) * 100.0, 0))
	add_central_force(transform.basis.z * input_gas * acceleration)
