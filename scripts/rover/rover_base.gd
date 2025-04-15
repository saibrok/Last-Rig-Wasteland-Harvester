extends Node2D

@onready var player: CharacterBody2D = $PlayerBase
@onready var background: Sprite2D = $Background
@onready var camera: Camera2D = $Camera2D
@onready var rest_hint: Node2D = $RestArea/RestHint/InteractionHint
@onready var exit_hint: Node2D = $ExitArea/ExitHint/InteractionHint
@onready var upgrade_hint: Node2D = $UpgradeArea/UpgradeHint/InteractionHint

var can_interact: bool = true
var in_rest_area: bool = false
var in_exit_area: bool = false
var in_upgrade_area: bool = false

func _ready():
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
		# Отключаем врагов
		for enemy in get_tree().get_nodes_in_group("enemy"):
			enemy.set_physics_process(false)
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
	get_tree().call_group("enemy", "set_target", GameManager.rover)

func _physics_process(delta):
	# Обновляем видимость подсказок
	rest_hint.visible = in_rest_area and can_interact
	exit_hint.visible = in_exit_area and can_interact
	upgrade_hint.visible = in_upgrade_area and can_interact

	# Обработка взаимодействия
	if Input.is_action_just_pressed("action_interact") and can_interact:
		if in_exit_area:
			print("RoverBase: action_interact pressed, returning to combat_arena")
			can_interact = false
			# Показываем боевую арену
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
					for child in GameManager.player.get_children():
						if child is Node2D:
							child.visible = true
					# Задержка включения ввода
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
			# Переключаем часть врагов на игрока
			var enemies = get_tree().get_nodes_in_group("enemy")
			var switch_count = enemies.size() / 2 # Половина врагов
			for i in range(min(switch_count, enemies.size())):
				if enemies[i] and GameManager.player:
					enemies[i].set_target(GameManager.player)
			# Отключаем свою камеру и удаляем сцену
			if camera:
				camera.enabled = false
			get_tree().current_scene = GameManager.combat_arena
			queue_free()
		elif in_rest_area:
			print("RoverBase: action_interact pressed, resting")
			# TODO: Реализовать логику отдыха (например, восстановление здоровья)
		elif in_upgrade_area:
			print("RoverBase: action_interact pressed, opening upgrade menu")
			# TODO: Реализовать открытие меню улучшений

func _on_rest_area_body_entered(body):
	if body == player:
		in_rest_area = true

func _on_rest_area_body_exited(body):
	if body == player:
		in_rest_area = false

func _on_exit_area_body_entered(body):
	if body == player:
		in_exit_area = true

func _on_exit_area_body_exited(body):
	if body == player:
		in_exit_area = false

func _on_upgrade_area_body_entered(body):
	if body == player:
		in_upgrade_area = true

func _on_upgrade_area_body_exited(body):
	if body == player:
		in_upgrade_area = false
