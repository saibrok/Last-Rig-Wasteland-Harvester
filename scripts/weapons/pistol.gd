## Класс пистолета, наследующий базовый класс оружия.
extends Weapon

## Инициализирует параметры пистолета.
func _ready() -> void:
	fire_rate = 6.0
	spread = 5.0
	barrel_offset = -2.0
	projectile_scene = preload("res://scenes/projectiles/pistol_projectile.tscn")
