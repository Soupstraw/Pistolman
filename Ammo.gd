extends Node2D

export(int) var ammo_count = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func on_enter(body):
	if body.is_in_group("Player"):
		var magazines = get_node("/root/MainScene/CanvasLayer/Control/Control/Viewport/Node2D")
		magazines.add_bullets(ammo_count)
		GameLogic.play_audio("res://Sounds/467610__triqystudio__pickupitem.wav")
		queue_free()
