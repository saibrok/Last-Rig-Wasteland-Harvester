extends CharacterBody2D

@export var walk_speed: float = 150.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var margin: float = 150
var scene_width: float = 640

func _ready():
	if not sprite.sprite_frames.has_animation("run"):
		push_error("Missing 'run' animation in AnimatedSprite2D")

func _physics_process(_delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x = walk_speed
	elif Input.is_action_pressed("move_left"):
		velocity.x = -walk_speed
	
	self.velocity = velocity
	move_and_slide()
	
	# Ограничиваем движение игрока внутри Ровера
	position.x = clamp(position.x, margin, scene_width - margin)
	position.y = 235
	
	# Обновляем анимацию и поворот спрайта
	if velocity.x != 0:
		sprite.play("run")
		sprite.flip_h = velocity.x < 0
		sprite.speed_scale = 1.0
	else:
		sprite.play("run") # Нет idle, используем run с низкой скоростью
		sprite.speed_scale = 0.2
