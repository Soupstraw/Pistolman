extends "res://Unit.gd"

enum AI_STATE {
	IDLE,
	PATROLING,
	CHASING,
	SHOOTING
}

export(int) var idle_wait_min = 3
export(int) var idle_wait_max = 10
export(float) var patrol_speed = 1000
export(float) var chase_speed = 4000
export(float) var reaction_time = 0.1
export(float) var fire_cooldown = 0.3
export(float) var alert_time = 7
export(float) var chase_wait_time = 1
export(float) var search_distance = 100
export(float) var inac_speed = 1
export(float) var inaccuracy = 100
export(bool) var patrols = true
export(bool) var lobotomized = false

onready var patrol_points = get_node("/root/MainScene/PatrolPoints").get_children()
onready var navigation = get_node("/root/MainScene/Navigation2D")
onready var player = get_node("/root/MainScene/Player")
onready var _self = self
onready var current_speed = patrol_speed

var ai_state
var patrol_target
var path
var path_ptr
var last_seen = null
var chasing_time = 0
var chase_wait = 0
var next_shot = 0
var wait_time = 0
onready var inac_phase = rand_range(0, 360)

# Called when the node enters the scene tree for the first time.
func _ready():
	_self.connect("on_hit", self, "goto_chasing", [true])
	goto_idle()

func _physics_process(delta):
	var seen = false
	if $Area2D.overlaps_body(player) and not GameLogic.is_game_over():
		$RayCast2D.set_cast_to($RayCast2D.global_transform.inverse() * player.global_position)
		$RayCast2D.force_raycast_update()
		var collider = $RayCast2D.get_collider()
		if collider == player:
			seen = true
			last_seen = player.global_position
			if ai_state != AI_STATE.SHOOTING:
				ai_state = AI_STATE.SHOOTING
				next_shot = reaction_time
	if not seen and ai_state == AI_STATE.SHOOTING:
		goto_chasing()

func goto_idle():
	ai_state = AI_STATE.IDLE
	wait_time = rand_range(idle_wait_min, idle_wait_max)

func goto_chasing(omniscient = false):
	chasing_time = 0
	ai_state = AI_STATE.CHASING
	$RayCast2D.position = Vector2(4, 4)
	current_speed = chase_speed
	if omniscient:
		last_seen = player.global_position
	path = navigation.get_simple_path(_self.global_position, last_seen, false)
	path_ptr = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not _self.alive:
		modulate = Color(.8, .5, .5)
		return

	if lobotomized: return

	if $PistolRaycast.is_colliding():
		$pistol.position.y = (transform.inverse() * $RayCast2D.get_collision_point()).y - 2
	else:
		$pistol.position.y = 8

	if ai_state == AI_STATE.IDLE:
		wait_time -= delta
		if wait_time <= 0 and patrols:
			patrol_target = patrol_points[randi() % len(patrol_points)].global_position
			path = navigation.get_simple_path(_self.global_position, patrol_target, false)
			path_ptr = 0
			ai_state = AI_STATE.PATROLING
	elif ai_state == AI_STATE.PATROLING:
		if not follow_path():
			goto_idle()
	elif ai_state == AI_STATE.SHOOTING:
		next_shot -= delta
		_self.look_at(player.global_position)
		$pistol.look_at(player.global_position)
		$pistol.rotate(sin(inac_phase + inac_speed * OS.get_ticks_msec()) * deg2rad(inaccuracy))
		if next_shot <= 0:
			_self.fire_pistol()
			next_shot = fire_cooldown
	elif ai_state == AI_STATE.CHASING:
		chasing_time += delta
		if chasing_time >= alert_time:
			current_speed = patrol_speed
			$RayCast2D.position = Vector2.ZERO
			goto_idle()
			return
		if not follow_path():
			if chase_wait < chase_wait_time:
				chase_wait += delta
				return
			var path_length = 999
			path_ptr = 0
			chase_wait = 0
			while path_length > search_distance:
				var rand_x = rand_range(-search_distance, search_distance)
				var rand_y = rand_range(-search_distance, search_distance)
				var new_target = _self.global_position + Vector2(rand_x, rand_y)
				path = navigation.get_simple_path(_self.global_position, new_target, false)
				if not path:
					continue
				var last_pos = path[0]
				path_length = 0
				for pos in path:
					path_length += last_pos.distance_to(pos)
					last_pos = pos

func follow_path():
	if path_ptr >= path.size():
		return false
	var next_point = path[path_ptr]
	var dist = _self.global_position.distance_to(next_point)
	if dist > 0.1:
		dist = _self.global_position.distance_to(next_point)
		var move_delta = (next_point - _self.global_position).normalized() * _self.get_process_delta_time() * current_speed
		move_delta = move_delta.clamped(dist)
		_self.translate(move_delta)
		_self.look_at(next_point)
	else:
		path_ptr += 1
	return true

func is_chasing():
	return ai_state == AI_STATE.CHASING

func is_aggroed():
	return ai_state == AI_STATE.CHASING or ai_state == AI_STATE.SHOOTING

func damage(pos, knife=false):
	var wound = null
	if knife:
		print("pos: ", pos)
		var facing = global_transform.x
		print("facing: ", facing)
		var angle = abs(pos.angle_to(facing))
		print("angle: ", rad2deg(angle))
		if angle < deg2rad(90):
			hitpoints -= 2
		else:
			hitpoints -= 3
		wound = load("res://KnifeWound.tscn").instance()
	else:
		hitpoints -= 1
		wound = load("res://BulletWound.tscn").instance()
	add_child(wound)
	wound.position = (pos - global_position).normalized() * rand_range(1, 5)
	wound.rotation = rand_range(0, 2*PI)
	emit_signal("on_hit")
	if hitpoints <= 0:
		die()
		

