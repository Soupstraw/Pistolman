extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var game_over = false
var victory = false
var levels = [
	"res://Level0.tscn",
	"res://Level1.tscn",
	"res://Level2.tscn",
	"res://Level3.tscn",
	"res://Level4.tscn",
	"res://GameOver.tscn",
]
var level_ptr = -1
var ammo = 0
var tank_controls = false

var music_volume = 0
var sfx_volume = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_pause_mode(PAUSE_MODE_PROCESS)

func reload():
	game_over = false
	victory = false
	get_tree().change_scene(levels[level_ptr])

func _input(event):
	if game_over and event is InputEventKey and get_node("/root/MainScene/CanvasLayer/Control/ColorRect").can_restart():
		reload()
	if event.is_action_pressed("Quit"):
		if level_ptr > -1:
			toggle_menu()
		elif level_ptr == len(levels) - 1:
			get_tree().quit()

func toggle_menu():
	var menu = get_node("/root/MainScene/CanvasLayer/Control/Menu")
	menu.visible = not menu.visible
	get_tree().paused = menu.visible

func _process(delta):
	if level_ptr > -1:
		var enemies = get_tree().get_nodes_in_group("Unit")
		var alive_enemies = 0
		for e in enemies:
			if e.alive: alive_enemies += 1
		if alive_enemies == 0 and not victory:
			victory()

func victory():
	ammo = get_node("/root/MainScene/CanvasLayer/Control/Control/Viewport/Node2D").count_ammo()
	victory = true
	game_over = true
	level_ptr += 1

func game_over():
	game_over = true

func is_game_over():
	return game_over

func is_victory():
	return victory

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func play_audio(clip):
	var audio_player = AudioStreamPlayer2D.new()
	audio_player.stream = load(clip)
	audio_player.connect("finished", self, "delete_object", [audio_player])
	audio_player.volume_db = sfx_volume
	add_child(audio_player)
	audio_player.play()

func continue():
	pass

func new_game():
	level_ptr = 0
	ammo = 0
	reload()

func quit():
	get_tree().quit()

func toggle_tank_controls(toggle):
	tank_controls = toggle

func set_music_volume(vol):
	if vol == -20:
		music_volume = -80
	else:
		music_volume = vol

func set_sfx_volume(vol):
	if vol == -20:
		sfx_volume = -80
	else:
		sfx_volume = vol
