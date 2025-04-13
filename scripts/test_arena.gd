extends Node2D


func _ready():
	# TranslationServer.set_locale("en") # Для английского
	TranslationServer.set_locale("ru") # Для русского (раскомментируй для теста)
	$Label.text = tr("welcome_message")
	$Label2.text = tr("drifter_intro")


func _process(delta: float) -> void:
	pass
