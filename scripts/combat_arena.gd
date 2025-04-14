extends Node2D

@onready var sandborn_scene: PackedScene = preload("res://scenes/enemies/sandborn.tscn")

func _ready():
	# Кастомный курсор
	var cursor_texture = preload("res://assets/crosshair_32x32.png")
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, Vector2(16, 16))
	
	# Спавним тестового Sandborn
	var sandborn = sandborn_scene.instantiate()
	sandborn.global_position = Vector2(100, 100) # Временная позиция
	add_child(sandborn)
