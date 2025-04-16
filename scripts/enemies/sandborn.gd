## Класс врага Sandborn, наследующий базовый класс Enemy, с уникальными визуальными эффектами и настройками.
class_name Sandborn
extends Enemy

## Анимированный спрайт для отображения движения врага.
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

## Метка для отображения текущего и максимального здоровья врага.
@onready var health_label: Label = $HealthLabel

## Инициализирует врага, запуская анимацию ходьбы и настраивая параметры.
func _ready() -> void:
	super._ready()
	if animated_sprite and animated_sprite.sprite_frames:
		animated_sprite.play("walk")
	_setup()

## Настраивает параметры врага, включая здоровье, скорость и анимации.
func _setup() -> void:
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

## Обновляет движение врага и его визуальные эффекты каждый физический кадр.
## @param delta Время, прошедшее с последнего кадра.
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_update_visuals()

## Обновляет ориентацию спрайта и анимацию в зависимости от направления и состояния бега.
func _update_visuals() -> void:
	if animated_sprite and animated_sprite.sprite_frames:
		animated_sprite.flip_h = global_position.direction_to(target.global_position).x < 0
		var anim = "run" if is_running else "walk"
		if animated_sprite.animation != anim:
			animated_sprite.play(anim)

## Наносит урон врагу и обновляет отображение здоровья.
## @param damage Количество урона.
func take_damage(damage: float) -> void:
	super.take_damage(damage)
	if health_label:
		health_label.text = "%d/%d" % [health, max_health]
