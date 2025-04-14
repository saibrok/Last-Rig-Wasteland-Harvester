class_name Enemy
extends CharacterBody2D

@export var max_health: float = 100.0
@export var walk_speed: float = 40.0
@export var run_speed: float = 80.0
@export var detection_range: float = 200.0

var health: float
var target: Node2D
var is_running: bool = false

func _ready():
	health = max_health
	add_to_group("enemy")

func _physics_process(delta):
	if not target:
		_find_target()
		return
	
	var direction = (target.global_position - global_position).normalized()
	var distance_to_target = global_position.distance_to(target.global_position)
	
	is_running = distance_to_target > detection_range * 0.5
	var current_speed = run_speed if is_running else walk_speed
	
	velocity = direction * current_speed
	move_and_slide()

func _find_target():
	var tree = get_tree()
	if tree:
		var drifter = tree.get_first_node_in_group("player")
		var rover = tree.get_first_node_in_group("rover")
		if drifter and rover:
			var dist_to_drifter = global_position.distance_to(drifter.global_position)
			var dist_to_rover = global_position.distance_to(rover.global_position)
			target = drifter if dist_to_drifter < dist_to_rover else rover
		else:
			target = drifter if drifter else rover

func take_damage(damage: float):
	health = max(0, health - damage)
	if health <= 0:
		die()

func die():
	queue_free()
