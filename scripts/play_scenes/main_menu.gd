extends Node2D

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/play_scenes/Game.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _successful_steam_connection() -> void:
	#get players icon to use in the "lobby", lobby should be offline until player invites someone / someone requests to join
	print(Steamworks.steam_image_texture)
	print("a")
	$"Lobby/GridContainer/1".texture = Steamworks.steam_image_texture

func _on_play_button_2_pressed() -> void:
	#temporary button, only used for me to work on the lobby stuff
	get_tree().change_scene_to_file("res://scenes/play_scenes/multiplayer_test/lobby_selector.tscn")

func _no_steam_connection() -> void:
	$Lobby.queue_free()
