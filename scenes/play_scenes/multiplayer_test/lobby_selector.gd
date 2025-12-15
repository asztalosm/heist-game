extends Node2D

var lobby_id = 0
var peer = SteamMultiplayerPeer.new()

func _ready():
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.avatar_loaded.connect(_on_loaded_avatar)

func spawn(data):
	var a = (load(data) as PackedScene).instantiate()
	return a

func _on_button_pressed():
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC)


func _on_lobby_created(success, id):
	if not success:
		print("baj van")
		return

	lobby_id = id
	print(lobby_id)

	Steam.setLobbyData(lobby_id, "name", Steam.getPersonaName() + "'s lobby")
	Steam.setLobbyJoinable(lobby_id, true)

	peer.create_host()
	multiplayer.multiplayer_peer = peer
	
	var label = Label.new()
	label.text = "lobby id: " + str(lobby_id)
	label.position = Vector2(1680, 0)
	add_child(label)

func _on_lobby_joined(lobby_id, steam_id, connect_result, is_friend):
	print("ebbe a lobbyBA LEPTEL: ", lobby_id)
	multiplayer.multiplayer_peer = peer
	_display_lobby_members(lobby_id)
	$CreateLobby.hide()
	$JoinLobby.hide()
	$TextEdit.hide()

	
func _on_join_lobby_pressed() -> void:
	var id_to_join = int($TextEdit.text.strip_edges())
	Steam.joinLobby(id_to_join)

func _display_lobby_members(lobby_id):
	var num_of_players = Steam.getNumLobbyMembers(lobby_id)
	print("ENNYI MEMBER VAN:", num_of_players)

	for i in range(num_of_players):
		var steam_id = Steam.getLobbyMemberByIndex(lobby_id, i)
		var username = Steam.getFriendPersonaName(steam_id)
		print("ember ", i, ":", username)
		Steam.getPlayerAvatar(steam_id)


#STEAM AVATAROKNAK A BETOLTESE
func _on_loaded_avatar(user_id: int, avatar_size: int, avatar_buffer:PackedByteArray) -> void:

	var avatar_image: Image = Image.create_from_data(avatar_size, avatar_size, false, Image.FORMAT_RGBA8, avatar_buffer)

	var avatar_texture: ImageTexture = ImageTexture.create_from_image(avatar_image)

	if $P1.texture == null:
		$P1.texture = avatar_texture
		$P1Name.text = Steam.getPersonaName()
	else:
		$P2.texture = avatar_texture
		$P2Name.text = Steam.getPersonaName()
