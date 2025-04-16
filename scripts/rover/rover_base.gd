## Класс сцены Ровера, управляющий взаимодействием игрока и переключением на боевую арену.
extends Node2D

## Игрок внутри Ровера.
@onready var player: CharacterBody2D = $PlayerBase

## Фоновый спрайт сцены.
@onready var background: Sprite2D = $Background

## Камера для сцены Ровера.
@onready var camera: Camera2D = $Camera2D

## Подсказка для зоны отдыха.
@onready var rest_hint: Node2D = $RestArea/RestHint/InteractionHint

## Подсказка для зоны выхода.
@onready var exit_hint: Node2D = $ExitArea/ExitHint/InteractionHint

## Подсказка для зоны улучшений.
@onready var upgrade_hint: Node2D = $UpgradeArea/UpgradeHint/InteractionHint

## Флаг, разрешающий взаимодействие.
var can_interact: bool = true

## Флаг, указывающий, находится ли игрок в зоне отдыха.
var in_rest_area: bool = false

## Флаг, указывающий, находится ли игрок в зоне выхода.
var in_exit_area: bool = false

## Флаг, указывающий, находится ли игрок в зоне улучшений.
var in_upgrade_area: bool = false

## Инициализирует сцену Ровера, настраивая камеру и отключая боевую арену.
func _ready() -> void:
	# Устанавливаем камеру
	if camera:
		camera.global_position = Vector2(320, 180)
		camera.enabled = true
	# Отключаем боевую арену
	if GameManager.combat_arena:
		GameManager.combat_arena.hide()
		if GameManager.combat_arena.camera:
			GameManager.combat_arena.camera.enabled = false
		if GameManager.player:
			GameManager.player.set_physics_process(false)
			GameManager.player.set_process(false)
			GameManager.player.set_process_input(false)
			if GameManager.player.has_node("CollisionShape2D"):
				GameManager.player.get_node("CollisionShape2D").disabled = true
			for child in GameManager.player.get_children():
				if child is Node2D:
					child.visible = false
		# Отключаем видимость врагов
		for enemy in get_tree().get_nodes_in_group("enemy"):
			enemy.set_process(false)
			if enemy.has_node("CollisionShape2D"):
				enemy.get_node("CollisionShape2D").disabled = true
			for child in enemy.get_children():
				if child is Node2D:
					child.visible = false
		# Останавливаем спавн
		if GameManager.combat_arena.spawn_timer:
			GameManager.combat_arena.spawn_timer.stop()
	# Сбрасываем курсор
	Input.set_custom_mouse_cursor(null)
	# Сигналим врагам переключиться на Ровер
	if GameManager.rover:
		get_tree().call_group("enemy", "set_target", GameManager.rover)
	else:
		print("Error: GameManager.rover is null in RoverBase")

## Обновляет видимость подсказок и обрабатывает взаимодействие игрока.
## @param delta Время, прошедшее с последнего кадра.
func _physics_process(delta: float) -> void:
	rest_hint.visible = in_rest_area and can_interact
	exit_hint.visible = in_exit_area and can_interact
	upgrade_hint.visible = in_upgrade_area and can_interact

	if Input.is_action_just_pressed("action_interact") and can_interact:
		if in_exit_area:
			print("RoverBase: action_interact pressed, returning to combat_arena")
			can_interact = false
			if GameManager.combat_arena:
				GameManager.combat_arena.show()
				GameManager.combat_arena.set_physics_process(true)
				GameManager.combat_arena.set_process(true)
				if GameManager.combat_arena.camera:
					GameManager.combat_arena.camera.enabled = true
				if GameManager.player:
					GameManager.player.set_physics_process(true)
					GameManager.player.set_process(true)
					if GameManager.player.has_node("CollisionShape2D"):
						GameManager.player.get_node("CollisionShape2D").disabled = false
					# Включаем процессы для всех дочерних узлов
					for child in GameManager.player.get_children():
						child.set_physics_process(true)
						child.set_process(true)
						if child is Node2D:
							child.visible = true
					var timer = get_tree().create_timer(0.2)
					timer.timeout.connect(func():
						if GameManager.player:
							GameManager.player.set_process_input(true)
					)
				# Включаем врагов
				for enemy in get_tree().get_nodes_in_group("enemy"):
					enemy.set_physics_process(true)
					enemy.set_process(true)
					if enemy.has_node("CollisionShape2D"):
						enemy.get_node("CollisionShape2D").disabled = false
					for child in enemy.get_children():
						if child is Node2D:
							child.visible = true
				# Запускаем спавн
				if GameManager.combat_arena.spawn_timer:
					GameManager.combat_arena.spawn_timer.start()
				# Восстанавливаем курсор
				var cursor_texture = preload("res://assets/crosshair_32x32.png")
				Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, Vector2(16, 16))
			# Переключаем половину врагов на игрока
			var enemies = get_tree().get_nodes_in_group("enemy")
			var switch_count = enemies.size() / 2
			for i in range(min(switch_count, enemies.size())):
				if enemies[i] and GameManager.player:
					enemies[i].set_target(GameManager.player)
			# Отключаем свою камеру и удаляем сцену
			if camera:
				camera.enabled = false
			get_tree().current_scene = GameManager.combat_arena
			queue_free()
			# Обновляем состояние
			GameManager.is_in_combat_arena = true
		elif in_rest_area:
			print("RoverBase: action_interact pressed, resting")
			# TODO: Реализовать логику отдыха
		elif in_upgrade_area:
			print("RoverBase: action_interact pressed, opening upgrade menu")
			# TODO: Реализовать открытие меню улучшений

## Обрабатывает вход игрока в зону отдыха.
## @param body Объект, вошедший в зону.
func _on_rest_area_body_entered(body: Node) -> void:
	if body == player:
		in_rest_area = true

## Обрабатывает выход игрока из зоны отдыха.
## @param body Объект, покинувший зону.
func _on_rest_area_body_exited(body: Node) -> void:
	if body == player:
		in_rest_area = false

## Обрабатывает вход игрока в зону выхода.
## @param body Объект, вошедший в зону.
func _on_exit_area_body_entered(body: Node) -> void:
	if body == player:
		in_exit_area = true

## Обрабатывает выход игрока из зоны выхода.
## @param body Объект, покинувший зону.
func _on_exit_area_body_exited(body: Node) -> void:
	if body == player:
		in_exit_area = false

## Обрабатывает вход игрока в зону улучшений.
## @param body Объект, вошедший в зону.
func _on_upgrade_area_body_entered(body: Node) -> void:
	if body == player:
		in_upgrade_area = true

## Обрабатывает выход игрока из зоны улучшений.
## @param body Объект, покинувший зону.
func _on_upgrade_area_body_exited(body: Node) -> void:
	if body == player:
		in_upgrade_area = false
