extends Node2D

@onready var game_container:=%GameContainer
@onready var game_over_control:=%GameOverControl

func _ready() -> void:
	game_over_control.visible=false

func _on_game_lost() -> void:
	var game=game_container.get_child(0)
	game.process_mode=Node.PROCESS_MODE_DISABLED
	game_over_control.visible=true

func _on_play_again_button_pressed() -> void:
	game_over_control.visible=false
	for child in game_container.get_children():
		child.queue_free()
		game_container.remove_child(child)
	var game_scene=preload("res://scenes/game.tscn")
	var game=game_scene.instantiate()
	game.lost.connect(_on_game_lost)
	game_container.add_child(game)
