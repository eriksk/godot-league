extends RigidBody

onready var wheel_front_left: Wheel = $Car/BottomPlate/Wheel_Front_Left
onready var wheel_front_right: Wheel = $Car/BottomPlate/Wheel_Front_Right
onready var wheel_back_left: Wheel = $Car/BottomPlate/Wheel_Back_Left
onready var wheel_back_right: Wheel = $Car/BottomPlate/Wheel_Back_Right

export var max_steer_angle_degrees: float = 35.0
export var steer_speed: float = 15.0
export var acceleration: float = 50.0
export var jump_force: float = 10.0
export var air_drag: float = 0.1
export var angular_damping: float = 10

var steering: float = 0.0
var input_steering: float = 0.0
var input_gas: float = 0.0
var input_jump: bool = false

var wheels: Array = []
var all_wheels_grounded = false
var wheels_grounded = 0

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

func jump():
	apply_impulse(Vector3.ZERO, transform.basis.y * jump_force * mass)

func _process(delta):
	input_steering = Input.get_axis("steer_right", "steer_left")
	input_gas =	Input.get_axis("reverse", "gas")
	input_jump = Input.is_action_just_pressed("jump")

	wheels_grounded = 0
	for wheel in wheels:
		if wheel.grounded:
			wheels_grounded += 1

	all_wheels_grounded = wheels_grounded == 4
		
	integrate_steering(delta)
	steer(steering * deg2rad(max_steer_angle_degrees))
	if input_jump and wheel_front_left.grounded:
		jump()

func _physics_process(_delta):
	if all_wheels_grounded:
		# acceleration
		add_central_force(transform.basis.z * input_gas * acceleration * mass)
		# wheel lateral forces
		apply_lateral_force()

	# steering
	add_torque(Vector3(0, steering * deg2rad(max_steer_angle_degrees) * 50.0 * mass, 0))
	# air drag
	add_central_force(-linear_velocity * air_drag * mass)
	# torque damping
	add_torque(-angular_velocity * angular_damping * mass)

func apply_lateral_force():
	# TODO: Per wheel lateral force?
	var velocity_direction = linear_velocity.normalized()
	var dot = transform.basis.x.dot(velocity_direction)
	add_central_force(-transform.basis.x * dot * linear_velocity.length() * mass * 20.0)
