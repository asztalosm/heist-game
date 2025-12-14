extends Node2D

func _on_leave_lobby_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/playScenes/mainMenu.tscn")
