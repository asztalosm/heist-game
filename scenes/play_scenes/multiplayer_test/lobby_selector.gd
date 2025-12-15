extends Node2D

var lobby_id = 0
var peer = SteamMultiplayerPeer.new()
var host_id = 0

func _ready():
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)

func _on_button_pressed():
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC)

func _on_lobby_created(success, id):
	if not success:
		return

	lobby_id = id
	host_id = Steam.getSteamID()
	

	Steam.setLobbyData(lobby_id, "name", Steam.getPersonaName() + "'s lobby")
	Steam.setLobbyJoinable(lobby_id, true)

	peer.create_host(0)
	multiplayer.multiplayer_peer = peer

	Steam.acceptP2PSessionWithUser(host_id)
	
	Steam.setLobbyMemberData(lobby_id, "ready", "0")

	print(lobby_id)

func _on_lobby_joined(lobby_id, steam_id, connect_result, is_friend):
	host_id = Steam.getLobbyOwner(lobby_id)

	if Steam.getSteamID() != host_id:
		peer.create_client(host_id)
		multiplayer.multiplayer_peer = peer

	var num_of_players = Steam.getNumLobbyMembers(lobby_id)
	for i in range(num_of_players):
		var sid = Steam.getLobbyMemberByIndex(lobby_id, i)
		Steam.acceptP2PSessionWithUser(sid)

	$CreateLobby.hide()
	$JoinLobby.hide()
	$TextEdit.hide()
	print(lobby_id)
	_update_player_names(lobby_id)
	


func _update_player_names(lobby_id):
	var num = Steam.getNumLobbyMembers(lobby_id)
	var names = []

	for i in range(num):
		var sid = Steam.getLobbyMemberByIndex(lobby_id, i)
		var name = Steam.getFriendPersonaName(sid)
		names.append(name)

	if names.size() > 0:
		$P1Name.text = names[0]
	if names.size() > 1:
		$P2Name.text = names[1]

func _on_join_lobby_pressed():
	var id_to_join = int($TextEdit.text.strip_edges())
	Steam.joinLobby(id_to_join)


func _on_lobby_chat_update(lobby_id, changed_id, making_change_id, chat_state):
	_update_player_names(lobby_id)
