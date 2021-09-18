extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$CenterContainer/HBoxContainer/VBoxContainer2/HSlider.value = GameLogic.music_volume
	$CenterContainer/HBoxContainer/VBoxContainer2/HSlider2.value = GameLogic.sfx_volume
	$CenterContainer/HBoxContainer/VBoxContainer/Quit.connect("pressed", GameLogic, "quit")
	$CenterContainer/HBoxContainer/VBoxContainer/NewGame.connect("pressed", GameLogic, "new_game")
	$CenterContainer/HBoxContainer/VBoxContainer/Continue.connect("pressed", GameLogic, "toggle_menu")
	$CenterContainer/HBoxContainer/VBoxContainer2/CheckBox.connect("toggled", GameLogic, "toggle_tank_controls")
	$CenterContainer/HBoxContainer/VBoxContainer2/HSlider.connect("value_changed", GameLogic, "set_music_volume")
	$CenterContainer/HBoxContainer/VBoxContainer2/HSlider2.connect("value_changed", GameLogic, "set_sfx_volume")
	if GameLogic.level_ptr == -1:
		$CenterContainer/HBoxContainer/VBoxContainer/Continue.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
