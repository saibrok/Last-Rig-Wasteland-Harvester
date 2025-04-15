extends Node2D

@export var spawn_interval: float = 2.0 # Интервал спавна в секундах
@onready var sandborn_scene: PackedScene = preload("res://scenes/enemies/sandborn.tscn")
@onready var player: Node2D = $Player
@onready var camera: Camera2D = $Camera2D
@onready var spawn_timer: Timer = $SpawnTimer

func _ready():
	
	var background = $Background
	if background:
		background.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	
	# Настраиваем таймер
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()
	
	# Начальный враг для теста
	var sandborn = sandborn_scene.instantiate()
	sandborn.global_position = Vector2(100, 100)
	add_child(sandborn)

func _physics_process(delta):
	if player and camera:
		camera.global_position = player.global_position

func _on_spawn_timer_timeout():
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
	if player:
		var distance_to_player = spawn_pos.distance_to(player.global_position)
		if distance_to_player < player_safe_radius:
			# Корректируем позицию, если слишком близко
			var direction = (spawn_pos - player.global_position).normalized()
			spawn_pos = player.global_position + direction * player_safe_radius
	
	# Ограничиваем позицию ареной
	spawn_pos = spawn_pos.clamp(Vector2(spawn_margin, spawn_margin), arena_size - Vector2(spawn_margin, spawn_margin))
	
	sandborn.global_position = spawn_pos
	add_child(sandborn)
