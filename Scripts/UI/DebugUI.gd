extends Node

export(NodePath) var car_path
export(NodePath) var front_left_wheel_grounded_path
export(NodePath) var front_right_wheel_grounded_path
export(NodePath) var back_left_wheel_grounded_path
export(NodePath) var back_right_wheel_grounded_path
export(NodePath) var speed_path

var car: Car
var front_left_wheel_grounded: Label
var front_right_wheel_grounded: Label
var back_left_wheel_grounded: Label
var back_right_wheel_grounded: Label
var speed: Label

func _ready():
	car = get_node(car_path)
	front_left_wheel_grounded = get_node(front_left_wheel_grounded_path)
	front_right_wheel_grounded = get_node(front_right_wheel_grounded_path)
	back_left_wheel_grounded = get_node(back_left_wheel_grounded_path)
	back_right_wheel_grounded = get_node(back_right_wheel_grounded_path)
	speed = get_node(speed_path)

func _process(_delta):
	front_left_wheel_grounded.text = "%s" % car.wheel_front_left.grounded
	front_right_wheel_grounded.text = "%s" % car.wheel_front_right.grounded
	back_left_wheel_grounded.text = "%s" % car.wheel_back_left.grounded
	back_right_wheel_grounded.text = "%s" % car.wheel_back_right.grounded
	speed.text = "%s" % car.linear_velocity.length()
