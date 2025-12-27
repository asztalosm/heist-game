extends Node2D

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/play_scenes/Game.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_play_button_2_pressed() -> void:
	#temporary button, only used for me to work on the lobby stuff
	get_tree().change_scene_to_file("res://scenes/play_scenes/multiplayer_test/game_lobby.tscn")

func _no_steam_connection() -> void:
	$Lobby.queue_free()


func _on_create_lobby() -> void:
	Steamworks.create_lobby()
	refresh_lobby()


func refresh_lobby() -> void:
	if Steamworks.change_detected:
		print("lobby length: ", len(Steamworks.lobby_data), "\n", Steamworks.lobby_data)
		for players in Steamworks.lobby_data:
			$Lobby/GridContainer.get_node(str(players.number)).texture = players.steam_image_texture
			$Lobby/GridContainer.get_node(str(players.number)).tooltip_text = players.steam_username
		for avatars in range(len(Steamworks.lobby_data)+1, 4):
			$Lobby/GridContainer.get_node(str(avatars)).texture = load("res://resources/textures/sprites/missing_player.png")
#		if Steamworks.lobby_data == []:
#			$Lobby/GridContainer.get_node("1").texture = load("res://resources/textures/sprites/missing_player.png")
		Steamworks.change_detected = false


func _on_leave_lobby() -> void:
	Steamworks.leave_lobby()
	refresh_lobby()
