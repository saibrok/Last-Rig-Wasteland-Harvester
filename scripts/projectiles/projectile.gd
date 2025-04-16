## Базовый класс снаряда, который движется и наносит урон врагам при столкновении.
class_name Projectile
extends Area2D

## Скорость движения снаряда.
@export var speed: float = 200.0

## Урон, наносимый снарядом.
@export var damage: float = 20.0

## Обновляет позицию снаряда и удаляет его за пределами арены.
## @param delta Время, прошедшее с последнего кадра.
func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta
	var arena_size = Vector2(1280, 720)
	if position.x < 0 or position.x > arena_size.x or position.y < 0 or position.y > arena_size.y:
		queue_free()

## Обрабатывает столкновение с телом, нанося урон врагам и уничтожая снаряд.
## @param body Объект, с которым произошло столкновение.
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy"):
		body.take_damage(damage)
		queue_free()
