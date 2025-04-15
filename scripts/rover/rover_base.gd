extends Node2D

@onready var player: CharacterBody2D = $PlayerBase
@onready var background: Sprite2D = $Background

func _ready():
	# Устанавливаем камеру в центр сцены
	var camera = $Camera2D
	if camera:
		camera.global_position = Vector2(320, 180)

func _input(event):
	if event.is_action_pressed("action_interact"): # F для возврата в боевую арену
		get_tree().change_scene_to_file("res://scenes/combat_arena.tscn")
