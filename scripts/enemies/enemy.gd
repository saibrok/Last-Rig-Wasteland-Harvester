class_name Enemy
extends CharacterBody2D

@export var max_health: float = 100.0
@export var walk_speed: float = 40.0 # Скорость ходьбы (пиксели/сек)
@export var run_speed: float = 80.0 # Скорость бега (пиксели/сек)
@export var detection_range: float = 200.0 # Радиус, в котором враг замечает цель

var health: float
var target: Node2D # Цель (Дрифтер или Ровер)
var is_running: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	health = max_health
	# Настраиваем пиксель-арт четкость
	if sprite and sprite.texture:
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _physics_process(delta):
	if not target:
		_find_target()
		return
	
	var direction = (target.global_position - global_position).normalized()
	var distance_to_target = global_position.distance_to(target.global_position)
	
	# Определяем, бежать или идти
	is_running = distance_to_target > detection_range * 0.5
	var current_speed = run_speed if is_running else walk_speed
	
	# Движение
	velocity = direction * current_speed
	move_and_slide()
	
	# Поворот спрайта (flip_h для пиксель-арт)
	if sprite:
		sprite.flip_h = direction.x < 0

func _find_target():
	# Ищем Дрифтера или Ровер
	var tree = get_tree()
	if tree:
		var drifter = tree.get_first_node_in_group("player")
		var rover = tree.get_first_node_in_group("rover")
		# Приоритет: Дрифтер, если он ближе, иначе Ровер
		if drifter and rover:
			var dist_to_drifter = global_position.distance_to(drifter.global_position)
			var dist_to_rover = global_position.distance_to(rover.global_position)
			target = drifter if dist_to_drifter < dist_to_rover else rover
		else:
			target = drifter if drifter else rover

func take_damage(damage: float):
	health -= damage
	if health <= 0:
		die()

func die():
	queue_free() # Удаляем врага
	# Здесь можно добавить эффекты смерти (например, анимацию)
