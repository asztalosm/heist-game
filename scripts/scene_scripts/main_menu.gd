extends Node2D

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/play_scenes/Game.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _successful_steam_connection() -> void:
	#get players icon to use in the "lobby", lobby should be offline until player invites someone / someone requests to join
	$"Lobby/GridContainer/1".texture = Steamworks.steam_image_texture
	Steamworks.create_lobby()

func _on_play_button_2_pressed() -> void:
	#temporary button, only used for me to work on the lobby stuff
	get_tree().change_scene_to_file("res://scenes/play_scenes/multiplayer_test/lobby_selector.tscn")

func _no_steam_connection() -> void:
	$Lobby.queue_free()

func refresh_lobby_data() -> void:
	print(Steamworks.lobby_data)

func _on_create_lobby() -> void:
	Steamworks.create_lobby()


func _on_button_2_pressed() -> void:
	print(Steamworks.lobby_data, " lobby id: ", Steamworks.lobby_id)
<<<<<<< HEAD
=======
	print(Steam.getNumLobbyMembers(Steamworks.lobby_id))


func _on_timer_timeout() -> void:
	for players in Steamworks.lobby_data:
		get_node("Lobby/GridContainer").get_node(str(players.number)).texture = players.steam_image_texture
>>>>>>> refs/remotes/origin/main
