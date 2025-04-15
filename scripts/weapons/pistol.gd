extends Weapon

func _ready():
	fire_rate = 6.0
	spread = 5.0
	barrel_offset = -2.0 # Укажи расстояние от центра спрайта до ствола
	projectile_scene = preload("res://scenes/projectiles/pistol_projectile.tscn")
