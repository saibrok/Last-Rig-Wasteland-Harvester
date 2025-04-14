extends Enemy

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _setup():
	if animated_sprite and animated_sprite.sprite_frames:
		animated_sprite.play("walk") # По умолчанию анимация ходьбы
		animated_sprite.sprite_frames.set_animation_loop("walk", true)
		for animation in animated_sprite.sprite_frames.get_animation_names():
			animated_sprite.sprite_frames.set_animation_speed(animation, 8.0)
	if animated_sprite:
		animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	max_health = 120.0
	health = max_health
	walk_speed = 80.0
	run_speed = 160.0
	detection_range = 250.0

func _update_visuals(direction: Vector2):
	if animated_sprite:
		animated_sprite.flip_h = direction.x < 0
		animated_sprite.play("run" if is_running else "walk")
