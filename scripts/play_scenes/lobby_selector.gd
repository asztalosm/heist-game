extends Node2D

func _on_leave_lobby_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/play_scenes/main_menu.tscn")


func _on_create_lobby_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/play_scenes/lobby.tscn")
