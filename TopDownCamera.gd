extends Camera2D

export(NodePath) var follow_target
export(float) var move_speed
export(float) var damping_factor
export(float, 0, 1) var bias = 0.9

var follow_target_node

# Called when the node enters the scene tree for the first time.
func _ready():
	follow_target_node = get_node(follow_target)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not GameLogic.is_game_over():
		var target_pos = (1-bias) * follow_target_node.global_position + bias * get_global_mouse_position()
		var delta_vec = (target_pos - global_position)
		global_position += (delta_vec.normalized() * move_speed).clamped(delta_vec.length())
	else:
		var delta_vec = follow_target_node.global_position - global_position
		global_position += (delta_vec.normalized() * move_speed).clamped(delta_vec.length())
		zoom *= 0.99
		global_rotation += delta
		

func shake(dir):
	var time = 0
	while time < 1000:
		position += dir*sin(time*damping_factor)*exp(-time*damping_factor)
		yield(get_tree(), "idle_frame")
		time += get_process_delta_time()
	
