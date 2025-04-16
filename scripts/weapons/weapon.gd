## Базовый класс оружия, управляющий поворотом и стрельбой.
class_name Weapon
extends Node2D

## Частота стрельбы (выстрелов в секунду).
@export var fire_rate: float = 1.0

## Угол разброса снарядов в градусах.
@export var spread: float = 0.0

## Смещение ствола относительно центра спрайта (положительное — вниз).
@export var barrel_offset: float = 0.0

## Сцена снаряда для стрельбы.
var projectile_scene: PackedScene

## Флаг, разрешающий стрельбу.
var can_shoot: bool = true

## Узел для точки вращения оружия.
@onready var pivot: Marker2D = get_node_or_null("Pivot")

## Спрайт оружия.
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

## Узел для точки вылета снаряда.
@onready var muzzle: Node2D = get_node_or_null("Muzzle")

## Обновляет поворот оружия к курсору и обрабатывает стрельбу, если боевая арена активна.
## @param _delta Время, прошедшее с последнего кадра.
func _physics_process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	
	if pivot:
		var pivot_global_pos = pivot.global_position
		look_at(mouse_pos)
		global_position = pivot_global_pos - (pivot.position.rotated(rotation))
	else:
		look_at(mouse_pos)
	
	if sprite:
		var is_flipped = mouse_pos.x < global_position.x
		sprite.flip_v = is_flipped
		sprite.position.y = barrel_offset if is_flipped else -barrel_offset

	# Стрелять только если боевая арена активна
	if GameManager.is_in_combat_arena:
		if Input.is_action_pressed("action_fire"):
			shoot(direction)

## Создаёт снаряд и запускает его в указанном направлении.
## @param direction Направление выстрела.
func shoot(direction: Vector2) -> void:
	if can_shoot and projectile_scene:
		var projectile = projectile_scene.instantiate()
		projectile.global_position = muzzle.global_position if muzzle else global_position
		var spread_radians = deg_to_rad(randf_range(-spread / 2.0, spread / 2.0))
		projectile.rotation = rotation + spread_radians
		# Добавляем снаряд в CombatArena
		if GameManager.combat_arena:
			GameManager.combat_arena.add_child(projectile)
		else:
			get_tree().current_scene.add_child(projectile)
		can_shoot = false
		var cooldown = 1.0 / fire_rate
		await get_tree().create_timer(cooldown).timeout
		can_shoot = true
