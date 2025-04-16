## Класс игрока для боевой арены с движением и стрельбой.
extends CharacterBody2D

## Скорость бега игрока.
@export var run_speed: float = 100.0

## Скорость ходьбы игрока (при стрельбе).
@export var walk_speed: float = 50.0

## Размер экрана для ограничения движения.
var screen_size: Vector2

## Текущая скорость игрока (бег или ходьба).
var current_speed: float

## Анимированный спрайт для отображения движения игрока.
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

## Инициализирует игрока, устанавливая начальную позицию и проверяя анимации.
func _ready() -> void:
	screen_size = Vector2(1280, 720) # Новая арена
	var marker: Marker2D = get_parent().get_node("PlayerSpawn")
	if marker:
		global_position = marker.global_position
	else:
		global_position = screen_size / 2
	current_speed = run_speed
	if not sprite.sprite_frames.has_animation("run") or not sprite.sprite_frames.has_animation("idle"):
		push_error("Missing 'run' or 'idle' animation in AnimatedSprite2D")

## Обрабатывает движение, стрельбу и анимации игрока каждый физический кадр.
## @param _delta Время, прошедшее с последнего кадра.
func _physics_process(_delta: float) -> void:
	var velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = velocity.normalized() * current_speed
	self.velocity = velocity
	move_and_slide()
	position = position.clamp(Vector2.ZERO, screen_size)

	var is_shooting = Input.is_action_pressed("action_fire")
	if is_shooting:
		var mouse_pos = get_global_mouse_position()
		sprite.flip_h = mouse_pos.x < global_position.x
		current_speed = walk_speed
	else:
		current_speed = run_speed
		if velocity.x != 0:
			sprite.flip_h = velocity.x < 0

	if velocity.length() > 0:
		sprite.play("run")
		sprite.speed_scale = clamp(current_speed / run_speed, 0.5, 2.0)
	else:
		sprite.play("idle")
		sprite.speed_scale = 1.0
