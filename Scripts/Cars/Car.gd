extends RigidBody

onready var wheel_front_left: Wheel = $Car/BottomPlate/Wheel_Front_Left
onready var wheel_front_right: Wheel = $Car/BottomPlate/Wheel_Front_Right
onready var wheel_back_left: Wheel = $Car/BottomPlate/Wheel_Back_Left
onready var wheel_back_right: Wheel = $Car/BottomPlate/Wheel_Back_Right

export var max_steer_angle_degrees: float = 35.0
export var acceleration: float = 50.0
export var jump_force: float = 10.0
export var air_drag: float = 0.1
export var angular_damping: float = 10
export var roll_speed: float = 50.0
export var ground_steer_speed: float = 25.0
export var boost_force: float = 5.0

var left_right: float = 0.0
var up_down: float = 0.0
var roll: float = 0.0
var boost: bool = false

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
	
func update_state():
	wheels_grounded = 0
	for wheel in wheels:
		if wheel.grounded:
			wheels_grounded += 1

	all_wheels_grounded = wheels_grounded == 4

func _process(_delta):
	left_right = Input.get_axis("right", "left")
	up_down = Input.get_axis("back", "forward")
	roll = Input.get_axis("roll_left", "roll_right")
	input_gas =	Input.get_axis("reverse", "gas")
	input_jump = Input.is_action_just_pressed("jump")
	boost = Input.is_action_pressed("boost")
	
	left_right = clamp(left_right, -1.0, 1.0)
	up_down = clamp(up_down, -1.0, 1.0)
	roll = clamp(roll, -1.0, 1.0)

	update_state()
	steer(left_right * deg2rad(max_steer_angle_degrees))
	if input_jump and wheel_front_left.grounded:
		jump()

func _integrate_forces(state):
	if all_wheels_grounded:
		# acceleration
		state.add_central_force(transform.basis.z * input_gas * acceleration * mass)
		# wheel lateral forces
		apply_lateral_force(state)
		
	if not all_wheels_grounded:
		apply_air_rolls(state)

	if all_wheels_grounded:
		# steering
		state.add_torque(transform.basis.y * left_right * ground_steer_speed * mass)

	# air drag
	state.add_central_force(-state.linear_velocity * air_drag * mass)
	# torque damping
	state.add_torque(-state.angular_velocity * angular_damping * mass)
	# boost
	if boost:
		state.add_central_force(transform.basis.z * boost_force * mass)
	

func apply_air_rolls(state):
	# roll
	state.add_torque(transform.basis.z * roll * roll_speed * mass)
	# pitch
	state.add_torque(transform.basis.x * up_down * roll_speed * mass)
	# yaw
	state.add_torque(transform.basis.y * left_right * roll_speed * mass)
	

func apply_lateral_force(state):
	# TODO: Per wheel lateral force?
	var velocity_direction = state.linear_velocity.normalized()
	var dot = transform.basis.x.dot(velocity_direction)
	state.add_central_force(-transform.basis.x * dot * state.linear_velocity.length_squared() * mass)
