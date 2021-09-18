extends Node

var actionness = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var enemies = get_tree().get_nodes_in_group("Unit")
	var alerted = false
	for node in enemies:
		if node.is_aggroed() and node.alive:
			alerted = true
	$Action.volume_db = GameLogic.music_volume if alerted else -80
	$Calm.volume_db = GameLogic.music_volume if not alerted else -80
