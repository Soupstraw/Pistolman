extends Node2D

var magazines
var positions
var active_magazine = 0
var loaded = true
export(float) var reload_time = 1.2

# Called when the node enters the scene tree for the first time.
func _ready():
	magazines = $Magazines.get_children()
	positions = []
	for m in magazines:
		positions.append(m.position)
	remove_bullets()
	add_bullets(GameLogic.ammo)
	reload()

func _process(delta):
	$AudioStreamPlayer.volume_db = GameLogic.sfx_volume

func fire_bullet():
	if not loaded:
		return false
	return magazines[active_magazine].fire_bullet()

func remove_bullets():
	for m in magazines:
		while m.fire_bullet():
			pass

func count_ammo():
	var sum = 0
	for m in magazines:
		sum += len(m.bullets) - m.bullet_ptr
	return sum

func add_bullets(n):
	for _i in range(n):
		var best_ptr = 99
		var best_idx = -1
		for i in range(len(magazines)):
			var m = magazines[i]
			if m.bullet_ptr < best_ptr and m.bullet_ptr > 0 and i != active_magazine:
				best_ptr = magazines[i].bullet_ptr
				best_idx = i
		if best_idx != -1:
			magazines[best_idx].add_bullet()

func reload():
	var new_active = -1
	var most_bullets = -1
	for i in range(len(magazines)):
		var m = magazines[i]
		print(most_bullets)
		if m.num_bullets() > most_bullets:
			most_bullets = m.num_bullets()
			new_active = i
	if most_bullets == magazines[active_magazine].num_bullets():
		return
	reload_anim(new_active)

func reload_anim(new_active):
	if not loaded:
		return
	loaded = false
	$AudioStreamPlayer.play()
	var mag_time = 0
	while mag_time < reload_time/2:
		mag_time += get_process_delta_time()
		magazines[active_magazine].position += Vector2(-1, 2) * get_process_delta_time() * 100
		magazines[new_active].position += Vector2(-1, 2) * get_process_delta_time() * 50
		yield(get_tree(), "idle_frame")
	magazines[new_active].scale = Vector2.ONE
	magazines[active_magazine].scale = Vector2(.5, .5)
	var return_time = reload_time/2
	var offset = Vector2(-1, 2)
	while return_time > 0:
		magazines[active_magazine].position = positions[new_active] + offset * 50 * return_time
		magazines[new_active].position = Vector2.ZERO + offset * 100 * return_time
		yield(get_tree(), "idle_frame")
		return_time -= get_process_delta_time()
	magazines[active_magazine].position = positions[new_active]
	magazines[new_active].position = Vector2.ZERO
	yield($AudioStreamPlayer, "finished")
	active_magazine = new_active
	loaded = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
