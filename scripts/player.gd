extends CharacterBody2D

@export var run_speed: float = 100.0  # Скорость бега
@export var walk_speed: float = 50.0  # Скорость ходьбы (во время стрельбы)

var screen_size: Vector2
var current_speed: float

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D # Узел AnimatedSprite2D

func _ready():
	screen_size = get_viewport_rect().size
	var marker: Marker2D = get_parent().get_node("DrifterSpawn")
	if marker:
		global_position = marker.global_position
	else:
		global_position = screen_size / 2
	current_speed = run_speed  # Изначально используем скорость бега
	# Проверка наличия анимаций
	if not sprite.sprite_frames.has_animation("run") or not sprite.sprite_frames.has_animation("idle"):
		push_error("Missing 'run' or 'idle' animation in AnimatedSprite2D")

func _physics_process(_delta):
	# Движение
	var velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = velocity.normalized() * current_speed
	self.velocity = velocity
	move_and_slide()
	position = position.clamp(Vector2.ZERO, screen_size)

	# Проверка стрельбы
	var is_shooting = Input.is_action_pressed("action_fire") # Изменено на "action_fire"

	# Поворот спрайта
	if is_shooting:
		var mouse_pos = get_global_mouse_position()
		sprite.flip_h = mouse_pos.x < global_position.x  # Поворот к курсору
		current_speed = walk_speed  # Замедление при стрельбе
	else:
		current_speed = run_speed  # Возвращаем скорость бега
		if velocity.x != 0:
			sprite.flip_h = velocity.x < 0  # Поворот по направлению движения

	# Анимация и ее скорость
	if velocity.length() > 0:
		sprite.play("run")
		# Масштабируем скорость анимации пропорционально текущей скорости
		sprite.speed_scale = clamp(current_speed / run_speed, 0.5, 2.0)
	else:
		sprite.play("idle")
		sprite.speed_scale = 1.0  # Стандартная скорость для idle
