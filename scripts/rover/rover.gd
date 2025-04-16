## Класс Ровера, представляющий интерактивный объект в боевой арене.
extends StaticBody2D

## Подсказка для взаимодействия с Ровером.
@onready var interaction_hint: Node2D = $InteractionHint

## Инициализирует Ровер, добавляя его в группу "rover".
func _ready() -> void:
	add_to_group("rover")

## Обновляет видимость подсказки взаимодействия в зависимости от расстояния до игрока.
## @param _delta Время, прошедшее с последнего кадра.
func _physics_process(_delta: float) -> void:
	if GameManager.combat_arena and GameManager.player:
		var distance_to_player = global_position.distance_to(GameManager.player.global_position)
		var can_interact = GameManager.combat_arena.can_interact
		interaction_hint.visible = can_interact and distance_to_player < 100.0
