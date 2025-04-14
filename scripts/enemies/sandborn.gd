extends Enemy

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_label: Label = $HealthLabel

func _ready():
	super._ready()
	if animated_sprite and animated_sprite.sprite_frames:
		animated_sprite.play("walk")
	_setup()

func _setup():
	max_health = 120.0
	health = max_health
	walk_speed = 40.0
	run_speed = 80.0
	if animated_sprite:
		animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		if animated_sprite.sprite_frames:
			animated_sprite.sprite_frames.set_animation_loop("walk", true)
			animated_sprite.sprite_frames.set_animation_loop("run", true)
			for animation in animated_sprite.sprite_frames.get_animation_names():
				animated_sprite.sprite_frames.set_animation_speed(animation, 8.0)
	if health_label:
		health_label.text = "%d/%d" % [health, max_health]

func _physics_process(delta):
	super._physics_process(delta)
	_update_visuals()

func _update_visuals():
	if animated_sprite and animated_sprite.sprite_frames:
		animated_sprite.flip_h = global_position.direction_to(target.global_position).x < 0
		var anim = "run" if is_running else "walk"
		if animated_sprite.animation != anim:
			animated_sprite.play(anim)

func take_damage(damage: float):
	super.take_damage(damage)
	if health_label:
		health_label.text = "%d/%d" % [health, max_health]
