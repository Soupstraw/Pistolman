extends Node2D


var bullets
var bullet_ptr = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	bullets = $Bullets.get_children()

func fire_bullet():
	if bullet_ptr < len(bullets):
		bullets[len(bullets) - 1 - bullet_ptr].visible = false
		bullet_ptr += 1
		return true
	return false

func add_bullet():
	if bullet_ptr > 0:
		bullet_ptr -= 1
		bullets[len(bullets) - 1 - bullet_ptr].visible = true

func num_bullets():
	return len(bullets) - bullet_ptr

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
