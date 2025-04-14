class_name Projectile
extends Area2D

@export var speed: float = 200.0
@export var damage: float = 20.0

func _physics_process(delta):
	position += transform.x * speed * delta
	var screen_size = get_viewport_rect().size
	if position.x < 0 or position.x > screen_size.x or position.y < 0 or position.y > screen_size.y:
		queue_free()

func _on_body_entered(body):
	if not body.is_in_group("player"):
		queue_free()
