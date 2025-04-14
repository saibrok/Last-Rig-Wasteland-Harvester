extends Node2D

@onready var sandborn_scene: PackedScene = preload("res://scenes/enemies/sandborn.tscn")
@onready var player: Node2D = $Player
@onready var camera: Camera2D = $Camera2D

func _ready():
	var sandborn = sandborn_scene.instantiate()
	sandborn.global_position = Vector2(100, 100)
	add_child(sandborn)
	var background = $Background
	if background:
		background.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED

func _physics_process(delta):
	if player and camera:
		camera.global_position = player.global_position
