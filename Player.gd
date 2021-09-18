extends "res://Unit.gd"

export(float) var moveSpeed = 20
export(float) var attack_delay = 1
export(float) var pistol_shake_multiplier = 0.1
export(float) var gunshot_range = 250
export(NodePath) var camera
export(NodePath) var magazines_path

onready var camera_node = get_node(camera)
onready var magazines = get_node(magazines_path)
onready var _self = self

var meleeing = false
var knife_hit = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$knife/Area2D/CollisionShape2D.disabled = true
	pass # Replace with function body.


func _input(event):
	if GameLogic.is_game_over():
		return
	if event.is_action_pressed("Fire"):
		if magazines.fire_bullet():
			_self.fire_pistol()
			camera_node.shake((_self.global_position - _self.get_global_mouse_position()).normalized() * pistol_shake_multiplier);
			for e in get_tree().get_nodes_in_group("Unit"):
				if e.global_position.distance_to(global_position) < gunshot_range:
					e.goto_chasing(true)
		else:
			GameLogic.play_audio("res://Sounds/467183__sophia-c__pistol-dry-fire-bersa-bp9cc-9x19.wav")
	elif event.is_action_pressed("Melee") and not meleeing:
		knife_hit = false
		melee_attack()
	elif event.is_action_pressed("Reload") and not meleeing:
		magazines.reload()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameLogic.is_game_over():
		return
	var mouse_pos = _self.get_global_mouse_position()
	_self.look_at(mouse_pos)
	if $RayCast2D.is_colliding():
		$pistol.position.y = (transform.inverse() * $RayCast2D.get_collision_point()).y - 2
	else:
		$pistol.position.y = 8
	$pistol.look_at(mouse_pos)

	var moveVec = Vector2.ZERO
	if Input.is_action_pressed("Move Up"):
		moveVec += Vector2.UP
	if Input.is_action_pressed("Move Down"):
		moveVec += Vector2.DOWN
	if Input.is_action_pressed("Move Left"):
		moveVec += Vector2.LEFT
	if Input.is_action_pressed("Move Right"):
		moveVec += Vector2.RIGHT
	if GameLogic.tank_controls:
		var trans = global_transform
		trans.origin = Vector2.ZERO
		moveVec = trans * moveVec
		moveVec = moveVec.rotated(PI/2)
	_self.move_and_slide(moveVec.normalized() * delta * moveSpeed)

func delete_object(obj):
	obj.queue_free()

func die():
	GameLogic.game_over()

func melee_attack():
	meleeing = true
	GameLogic.play_audio("res://Sounds/118792__lmbubec__1-knife-slash-a.wav")
	$knife/Area2D/CollisionShape2D.disabled = false
	$knife.visible = true
	$AnimationPlayer.play("stab")
	yield($AnimationPlayer, "animation_finished")
	$knife/Area2D/CollisionShape2D.disabled = true
	$knife.visible = false
	meleeing = false


func on_stab_hit(body):
	if body.is_in_group("Unit") and not knife_hit:
		knife_hit = true
		GameLogic.play_audio("res://Sounds/435238__aris621__nasty-knife-stab.wav")
		body.damage(global_position - body.global_position, true)
	
