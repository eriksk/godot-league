extends Camera

export(NodePath) var target_node;
export(NodePath) var ball_target_node;

var target;

func _ready():
	target = get_node(target_node)

func _process(_delta):
	look_at(target.translation, Vector3.UP)
