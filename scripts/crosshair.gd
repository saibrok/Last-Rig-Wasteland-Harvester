## Класс для установки кастомного курсора прицела.
extends Node2D

## Устанавливает текстуру кастомного курсора прицела при инициализации.
func _ready() -> void:
	# Загружаем текстуру курсора
	var cursor_texture = preload("res://assets/crosshair_32x32.png")
	# Устанавливаем кастомный курсор (32x32, центр в середине)
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, Vector2(16, 16))
