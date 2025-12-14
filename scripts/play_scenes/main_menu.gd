extends Node2D

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/play_scenes/lobby_selector.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
	
