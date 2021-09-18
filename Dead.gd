extends ColorRect

var time_passed = 0
var text_added = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous rame.
func _process(delta):
	$Label.visible = GameLogic.is_game_over()
	if GameLogic.is_victory():
		if not text_added:
			$Label.text = "Level completed"
			time_passed += delta
	elif GameLogic.is_game_over():
		if not text_added:
			$Label.text = "You died"
			time_passed += delta
	else:
		$Label.text = ""
		time_passed = 0
		text_added = false

	if time_passed > 3 and not text_added:
		$Label.text += "\nPress any key"
		text_added = true
	modulate.a = 1 - exp(-time_passed)

func can_restart():
	return text_added
