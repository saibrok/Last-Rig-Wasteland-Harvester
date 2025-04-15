extends StaticBody2D

@onready var interaction_hint: Node2D = $InteractionHint

func _ready():
	add_to_group("rover")

func _physics_process(_delta):
	if GameManager.combat_arena and GameManager.player:
		var distance_to_player = global_position.distance_to(GameManager.player.global_position)
		var can_interact = GameManager.combat_arena.can_interact
		interaction_hint.visible = can_interact and distance_to_player < 100.0
