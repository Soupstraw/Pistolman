extends KinematicBody2D

const Unit = preload("Unit.gd")

export(float) var bullet_speed
export(float) var fade_speed = 0.9
export(float) var damage = 1
var collided = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not collided:
		var collision = move_and_collide(-transform.y * bullet_speed * delta)
		if collision:
			set_collision_mask(0)
			set_collision_layer(0)
			collided = true
			if collision.collider is Unit:
				collision.collider.damage(collision.position)
				play_oneshot(load("res://Sounds/522091__magnuswaker__pound-of-flesh-1.wav"))
				$BloodParticles.emitting = true
			else:
				play_oneshot(load("res://Sounds/522506__filmmakersmanual__bullet-metal-hit-2.wav"))
				$Particles2D.emitting = true
			fade_away()

func fade_away():
	var trail_len = 1
	while trail_len > 0 or $BloodParticles.emitting or $Particles2D.emitting:
		trail_len -= get_process_delta_time() * fade_speed
		$Line2D.points[1].x = min(-10 * trail_len, 0)
		yield(get_tree(), "idle_frame")
	queue_free()

func play_oneshot(audio):
	var audio_player = AudioStreamPlayer2D.new()
	audio_player.stream = audio
	audio_player.connect("finished", self, "delete_object", [audio_player])
	add_child(audio_player)
	audio_player.play()
	
