extends Node
#this is the script that handles lobbies

var steam_id = 0
var steam_username = null
var lobby_id = 0
var steam_initialized = false
var menu_scene
var steam_image_texture: ImageTexture
var lobby_data = []
var fake_ip_data = []
var lobby_created = false

func _process(_delta: float) -> void:
	Steam.run_callbacks()



func create_lobby() -> void:
	lobby_data.clear()
	lobby_id = steam_id
	lobby_data.append({"lobby_place": 1, "steam_id": steam_id, "steam_username": steam_username, "steam_image_texture": steam_image_texture})
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, 4)
	print(lobby_data)
	Steam.beginAsyncRequestFakeIP(1)
	Steam.fake_ip_result.connect(func fake_ip(result: int, remote_fake_steam_id: int, fake_ip: String, port_list: Array) -> void:
		fake_ip_data = [result, remote_fake_steam_id, fake_ip, port_list]
		lobby_created = true)

func join_lobby(this_lobby_id: int, this_steam_id: int) -> void:
	print("lobby join", this_lobby_id, this_steam_id)

func _on_lobby_chat_update(this_lobby_id: int, changed_id: int, making_change_id: int, chat_state: int) -> void:
	print(this_lobby_id, changed_id, making_change_id, chat_state)

func set_user_variables() -> void:
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()
	Steam.getPlayerAvatar()
	Steam.avatar_loaded.connect(func load_avatars(_avatar_id: int, size: int, data: PackedByteArray) -> void: #inline function
		var steam_image: Image = Image.create_from_data(size, size, false,Image.FORMAT_RGBA8, data)
		steam_image_texture = ImageTexture.create_from_image(steam_image)
		print("image loaded"))
	steam_initialized = true
	Steam.join_requested.connect(join_lobby)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)


func _ready() -> void:
	var response = Steam.steamInitEx(480)
	if response.status == 0:
		print("steam connected succesfully")
		set_user_variables()
		Steam.activateGameOverlay()
		
	else:
		push_error("Steam couldn't connect succesfully - ", response)
