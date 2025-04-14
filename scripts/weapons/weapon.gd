class_name Weapon
extends Node2D

@export var fire_rate: float = 1.0
@export var spread: float = 0.0
@export var barrel_offset: float = 0.0 # Расстояние от центра спрайта до ствола (вниз - положительное)

var projectile_scene: PackedScene
var can_shoot: bool = true

@onready var pivot: Marker2D = get_node_or_null("Pivot") # Узел для точки вращения
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var muzzle: Node2D = get_node_or_null("Muzzle")

func _physics_process(_delta):
	# Поворот к курсору
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	
	if pivot:
		# Вращение вокруг Pivot
		var pivot_global_pos = pivot.global_position
		look_at(mouse_pos)
		# Корректируем позицию оружия, чтобы Pivot оставался на месте
		global_position = pivot_global_pos - (pivot.position.rotated(rotation))
	else:
		# Вращение вокруг центра Node2D
		look_at(mouse_pos)
	
	# Разворот спрайта с осью отзеркаливания на Y=0
	if sprite:
		var is_flipped = mouse_pos.x < global_position.x
		sprite.flip_v = is_flipped
		# Корректируем позицию спрайта, чтобы ствол (barrel_offset) был на Y=0
		sprite.position.y = barrel_offset if is_flipped else -barrel_offset

	# Стрельба
	if Input.is_action_pressed("action_fire"):
		shoot(direction)

func shoot(direction: Vector2):
	if can_shoot and projectile_scene:
		var projectile = projectile_scene.instantiate()
		projectile.global_position = muzzle.global_position if muzzle else global_position
		
		# Добавляем случайный разброс к углу
		var spread_radians = deg_to_rad(randf_range(-spread / 2.0, spread / 2.0))
		projectile.rotation = rotation + spread_radians
		
		get_tree().current_scene.add_child(projectile)
		can_shoot = false
		var cooldown = 1.0 / fire_rate
		await get_tree().create_timer(cooldown).timeout
		can_shoot = true
