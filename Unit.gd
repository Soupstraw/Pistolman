extends KinematicBody2D

class_name Unit

signal on_hit

var bullet = load("res://Bullet.tscn")
var gunshot_sfx = load("res://Sounds/427592__michorvath__9mm-pistol-shot.wav")
export(int) var hitpoints = 3
var alive = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func fire_pistol():
	var new_bullet = bullet.instance()
	get_tree().get_root().add_child(new_bullet)
	var audio_player = AudioStreamPlayer2D.new()
	audio_player.stream = gunshot_sfx
	audio_player.connect("finished", self, "delete_object", [audio_player])
	add_child(audio_player)
	audio_player.play()
	new_bullet.position = $pistol.global_position
	new_bullet.rotation = $pistol.global_rotation + deg2rad(90)
	new_bullet.add_collision_exception_with(self)
	pass

func damage(pos, knife=false):
	var wound
	if knife:
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

func die():
	alive = false
	set_collision_layer(0)
	set_collision_mask(0)

