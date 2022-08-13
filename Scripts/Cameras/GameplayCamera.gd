extends Camera

export(NodePath) var target_node;
export(NodePath) var ball_target_node;

export var height = 2.0
export var distance = 5.0
export var min_height = 2.0
export var is_ball_cam = true

var target;
var ball;

func _ready():
	target = get_node(target_node)
	ball = get_node(ball_target_node)

func _process(delta):
	if is_ball_cam: 
		update_ball_cam(delta)
	# look_at(ball.translation, Vector3.UP)

func update_ball_cam(_delta):
	var ball_position = ball.global_translation
	var target_position = target.global_translation
	var direction_to_ball = target_position.direction_to(ball_position)

	var up = Vector3.UP # TODO: this should be relative to direction to ball

	var camera_target_position = target_position + (-direction_to_ball * distance) + (up * height)

	if camera_target_position.y < min_height:
		camera_target_position.y = min_height

	global_translation = camera_target_position
	
	look_at(ball_position, Vector3.UP)
