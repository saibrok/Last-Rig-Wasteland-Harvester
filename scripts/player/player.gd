extends CharacterBody2D

@export var run_speed: float = 100.0
@export var walk_speed: float = 50.0

var screen_size: Vector2
var current_speed: float

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	screen_size = Vector2(1280, 720) # Новая арена
	var marker: Marker2D = get_parent().get_node("PlayerSpawn")
	if marker:
		global_position = marker.global_position
	else:
		global_position = screen_size / 2
	current_speed = run_speed
	if not sprite.sprite_frames.has_animation("run") or not sprite.sprite_frames.has_animation("idle"):
		push_error("Missing 'run' or 'idle' animation in AnimatedSprite2D")

func _physics_process(_delta):
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
