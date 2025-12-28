extends Node2D
var peer

func play_singleplayer() -> void:
	print("sp")

func play_multiplayer() -> void:
	print("mp")

func _add_player(id: int = 1):
	var player_scene = load("res://scenes/play_scenes/player/player.tscn")
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)

func _remove_player(id: int = 1):
	if !self.has_node(str(id)):
		return
	call_deferred("queue_free", self.get_node(str(id)))

func _ready() -> void:
	if Steamworks.lobby_data == []:
		print("lobby data unavailable - player has no steam connection or didn't make lobby")
		play_singleplayer()
	else:
		print("lobby data available")
		play_multiplayer()
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_add_player)
		multiplayer.peer_disconnected.connect(_remove_player)
		_add_player()



#func _process(delta: float) -> void:
#	pass
