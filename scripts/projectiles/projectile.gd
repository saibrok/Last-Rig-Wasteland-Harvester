class_name Projectile
extends Area2D

@export var speed: float = 200.0
@export var damage: float = 20.0

func _physics_process(delta):
	position += transform.x * speed * delta
	var arena_size = Vector2(1280, 720)
	if position.x < 0 or position.x > arena_size.x or position.y < 0 or position.y > arena_size.y:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_damage(damage)
		queue_free()
