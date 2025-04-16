## Базовый класс врага, который преследует игрока или Ровер, в зависимости от расстояния.
class_name Enemy
extends CharacterBody2D

## Максимальное здоровье врага.
@export var max_health: float = 100.0

## Скорость ходьбы врага (медленное движение).
@export var walk_speed: float = 40.0

## Скорость бега врага (быстрое движение при большом расстоянии до цели).
@export var run_speed: float = 80.0

## Радиус обнаружения цели, определяющий, когда враг начинает преследование.
@export var detection_range: float = 200.0

## Текущее здоровье врага.
var health: float

## Цель, за которой следует враг (игрок или Ровер).
var target: Node2D

## Флаг, указывающий, бежит ли враг (true) или идёт (false).
var is_running: bool = false

## Инициализирует врага, устанавливая начальное здоровье и добавляя его в группу "enemy".
func _ready() -> void:
	health = max_health
	add_to_group("enemy")

## Обновляет движение врага каждый физический кадр.
## @param delta Время, прошедшее с последнего кадра.
func _physics_process(delta: float) -> void:
	if not target:
		_find_target()
		return
	
	var direction = (target.global_position - global_position).normalized()
	var distance_to_target = global_position.distance_to(target.global_position)
	
	is_running = distance_to_target > detection_range * 0.5
	var current_speed = run_speed if is_running else walk_speed
	
	velocity = direction * current_speed
	move_and_slide()

## Находит ближайшую цель (игрок или Ровер) для преследования.
func _find_target() -> void:
	var tree = get_tree()
	if tree:
		var drifter = tree.get_first_node_in_group("player")
		var rover = tree.get_first_node_in_group("rover")
		if drifter and rover:
			var dist_to_drifter = global_position.distance_to(drifter.global_position)
			var dist_to_rover = global_position.distance_to(rover.global_position)
			target = drifter if dist_to_drifter < dist_to_rover else rover
		else:
			target = drifter if drifter else rover

## Устанавливает новую цель для преследования.
## @param new_target Новая цель (игрок или Ровер).
func set_target(new_target: Node2D) -> void:
	target = new_target

## Наносит урон врагу и проверяет, не погиб ли он.
## @param damage Количество урона.
func take_damage(damage: float) -> void:
	health = max(0, health - damage)
	if health <= 0:
		die()

## Уничтожает врага, удаляя его из сцены.
func die() -> void:
	queue_free()