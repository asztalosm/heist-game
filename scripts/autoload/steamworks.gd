extends Node
#this is the script that handles lobbies

var steam_id = 0
var steam_username = null
var lobby_id = 0
var steam_initialized = false
var menu_scene
var steam_image_texture: ImageTexture
var lobby_data = []
var lobby_created = false
var peer
var temporary_image: ImageTexture

func _process(_delta: float) -> void:
	Steam.run_callbacks()

func _on_lobby_joined(lobby: int, _permissions: int, _locked: bool, _response: int):
	lobby_id = lobby
	print("lobby (%s) joined" % lobby_id)
	print(Steam.getNumLobbyMembers(lobby_id))

func _on_player_disconnected(disconnect_steam_id: int) -> void:
	print(disconnect_steam_id, " disconnected")

func _on_lobby_created(result:int, new_lobby_id: int) -> void:
	if result == Steam.Result.RESULT_OK:
		lobby_id = new_lobby_id
		lobby_data.append({"number": 1, "steam_id": steam_id, "steam_username": steam_username, "steam_image_texture": steam_image_texture})


func create_lobby() -> void:
	lobby_data.clear()
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, 4)
	print(lobby_data)

func join_lobby(this_lobby_id: int, _this_steam_id: int) -> void:
	Steam.joinLobby(this_lobby_id)

func _on_lobby_chat_update(this_lobby_id: int, _changed_id: int, making_change_id: int, chat_state: int) -> void:
	if chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
		Steam.getPlayerAvatar(2, making_change_id)
		Steam.avatar_loaded.connect(func load_avatars(_avatar_id: int, size: int, data: PackedByteArray) -> void: #inline function
			var steam_image: Image = Image.create_from_data(size, size, false,Image.FORMAT_RGBA8, data)
			steam_image.resize(48,48, Image.INTERPOLATE_LANCZOS)
			temporary_image = ImageTexture.create_from_image(steam_image)
			lobby_data.append({"number": len(lobby_data)+1, "steam_id": making_change_id, "steam_username": Steam.getFriendPersonaName(making_change_id), "steam_image_texture": temporary_image})) #ugly way to get avatar and will probably bite me in the ass later but whatever
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_DISCONNECTED:
		lobby_data.erase({"number": len(lobby_data)+1, "steam_id": making_change_id, "steam_username": Steam.getFriendPersonaName(making_change_id), "steam_image_texture": null})
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_LEFT:
		lobby_data.erase({"number": len(lobby_data)+1, "steam_id": making_change_id, "steam_username": Steam.getFriendPersonaName(making_change_id), "steam_image_texture": null})
	

func set_user_variables() -> void:
	steam_id = Steam.getSteamID()
	print("client steam id: ", steam_id)
	steam_username = Steam.getPersonaName()
	Steam.getPlayerAvatar()
	Steam.avatar_loaded.connect(func load_avatars(_avatar_id: int, size: int, data: PackedByteArray) -> void: #inline function
		var steam_image: Image = Image.create_from_data(size, size, false,Image.FORMAT_RGBA8, data)
		steam_image.resize(48,48, Image.INTERPOLATE_LANCZOS)
		steam_image_texture = ImageTexture.create_from_image(steam_image))
	steam_initialized = true
	Steam.join_requested.connect(join_lobby)
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)


func _ready() -> void:
	var response = Steam.steamInitEx(480)
	if response.status == 0:
		print("steam connected succesfully")
		set_user_variables()
		Steam.activateGameOverlay()
		Steam.initRelayNetworkAccess()
		
	else:
		push_error("Steam couldn't connect succesfully - ", response)
