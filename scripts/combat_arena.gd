extends Node2D

@export var spawn_interval: float = 2.0 # Интервал спавна в секунд
@onready var sandborn_scene: PackedScene = preload("res://scenes/enemies/sandborn.tscn")
@onready var player: Node2D = $Player
@onready var camera: Camera2D = $Camera2D
@onready var rover: StaticBody2D = $Rover
@onready var spawn_timer: Timer = $SpawnTimer
var can_interact: bool = true

func _ready():
	# Сохраняем ссылки в GameManager
	GameManager.combat_arena = self
	GameManager.player = player
	GameManager.rover = rover
	if camera:
		camera.enabled = true
	
	# Загружаем текстуру курсора
	var cursor_texture = preload("res://assets/crosshair_32x32.png")
	# Устанавливаем кастомный курсор (32x32, центр в середине)
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, Vector2(16, 16))
	
	var background = $Background
	if background:
		background.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	
	# Настраиваем таймер
	if spawn_timer:
		spawn_timer.wait_time = spawn_interval
		spawn_timer.one_shot = false
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)
		spawn_timer.start()
	else:
		print("Error: SpawnTimer node not found in CombatArena at _ready")
	
	# Начальный враг для теста
	var sandborn = sandborn_scene.instantiate()
	sandborn.global_position = Vector2(100, 100)
	add_child(sandborn)

func _physics_process(delta):
	if is_visible() and player and camera:
		camera.global_position = player.global_position
	
	if Input.is_action_just_pressed("action_interact") and is_visible() and rover and can_interact:
		var distance_to_rover = player.global_position.distance_to(rover.global_position)
		print("CombatArena: action_interact pressed, distance: ", distance_to_rover)
		if distance_to_rover < 100.0: # Радиус взаимодействия
			can_interact = false
			# Инстанцируем rover_base.tscn
			var rover_base_scene = preload("res://scenes/rover/rover_base.tscn")
			var rover_base = rover_base_scene.instantiate()
			get_tree().root.add_child(rover_base)
			get_tree().current_scene = rover_base
			# Отключаем сцену полностью
			hide()
			set_physics_process(false)
			set_process(false)
			if camera:
				camera.enabled = false
			if player:
				player.set_physics_process(false)
				player.set_process(false)
				player.set_process_input(false)
				# Отключаем коллизии и рендеринг для игрока
				if player.has_node("CollisionShape2D"):
					player.get_node("CollisionShape2D").disabled = true
				for child in player.get_children():
					if child is Node2D:
						child.visible = false
			# Отключаем врагов и их коллизии
			for enemy in get_tree().get_nodes_in_group("enemy"):
				enemy.set_physics_process(false)
				enemy.set_process(false)
				if enemy.has_node("CollisionShape2D"):
					enemy.get_node("CollisionShape2D").disabled = true
				for child in enemy.get_children():
					if child is Node2D:
						child.visible = false
			# Останавливаем спавн
			if spawn_timer:
				spawn_timer.stop()
			# Сбрасываем курсор
			Input.set_custom_mouse_cursor(null)
			# Задержка для восстановления взаимодействия
			var timer = get_tree().create_timer(0.2)
			timer.timeout.connect(func(): can_interact = true)

func _on_spawn_timer_timeout():
	if not spawn_timer:
		print("Error: spawn_timer is null in _on_spawn_timer_timeout")
		return
	var sandborn = sandborn_scene.instantiate()
	
	# Случайная позиция по краям арены
	var arena_size = Vector2(1280, 720)
	var spawn_margin = 100.0 # Отступ от краёв
	var player_safe_radius = 200.0 # Минимальное расстояние от игрока
	var spawn_pos = Vector2.ZERO
	
	# Выбираем сторону спавна (0: лево, 1: право, 2: верх, 3: низ)
	var side = randi() % 4
	match side:
		0: # Лево
			spawn_pos.x = spawn_margin
			spawn_pos.y = randf_range(spawn_margin, arena_size.y - spawn_margin)
		1: # Право
			spawn_pos.x = arena_size.x - spawn_margin
			spawn_pos.y = randf_range(spawn_margin, arena_size.y - spawn_margin)
		2: # Верх
			spawn_pos.x = randf_range(spawn_margin, arena_size.x - spawn_margin)
			spawn_pos.y = spawn_margin
		3: # Низ
			spawn_pos.x = randf_range(spawn_margin, arena_size.x - spawn_margin)
			spawn_pos.y = arena_size.y - spawn_margin
	
	# Проверяем, что позиция не слишком близко к игроку
	if GameManager.player:
		var distance_to_player = spawn_pos.distance_to(GameManager.player.global_position)
		if distance_to_player < player_safe_radius:
			# Корректируем позицию, если слишком близко
			var direction = (spawn_pos - GameManager.player.global_position).normalized()
			spawn_pos = GameManager.player.global_position + direction * player_safe_radius
	
	# Ограничиваем позицию ареной
	spawn_pos = spawn_pos.clamp(Vector2(spawn_margin, spawn_margin), arena_size - Vector2(spawn_margin, spawn_margin))
	
	sandborn.global_position = spawn_pos
	add_child(sandborn)
