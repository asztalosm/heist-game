extends Node
#this is the script that handles lobbies

var steam_id = 0
var steam_username = null
var lobby_id = 0
var steam_initialized = false
var steam_image_texture: ImageTexture
var lobby_data = []
var lobby_created = false
var temporary_image: ImageTexture
var change_detected = false
var is_host = false
var peer

func _process(_delta: float) -> void:
	Steam.run_callbacks()

func _on_lobby_joined(lobby: int, _permissions: int, _locked: bool, _response: int):
	lobby_id = lobby
	get_lobby_data(lobby_id)


func _on_lobby_created(result:int, new_lobby_id: int) -> void:
	if result == Steam.Result.RESULT_OK:
		lobby_id = new_lobby_id
		is_host = true


func return_image_by_id(id):
	temporary_image = null
	#try to get image data
	Steam.getPlayerAvatar(2, id)
	Steam.avatar_loaded.connect(func _on_avatar_load(_avtar_id: int, size: int, data: PackedByteArray):
		var steam_image: Image = Image.create_from_data(size, size, false,Image.FORMAT_RGBA8, data)
		steam_image.resize(48,48, Image.INTERPOLATE_LANCZOS)
		temporary_image = ImageTexture.create_from_image(steam_image))
	while temporary_image == null:
		await get_tree().create_timer(0.1).timeout
	return temporary_image
	
func get_lobby_data(lobby: int):
	lobby_data.clear()
	var member_count = Steam.getNumLobbyMembers(lobby)
	print("lobby member count", member_count)
	for i in range(member_count):
		var member_id = Steam.getLobbyMemberByIndex(lobby, i)
		lobby_data.append({
			"number": i+1,
			"steam_id": member_id,
			"steam_username": Steam.getFriendPersonaName(member_id),
			"steam_image_texture": await return_image_by_id(member_id) #hopefully this doesnt leak memory or some shit cause its so hacky, might do a hashmap for this tho
		})
	change_detected = true
	return str("\nLobby player count: {count}\nLobby players data {data}").format({"count": member_count, "data": lobby_data})

func create_lobby() -> void:
	lobby_data.clear()
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, 4)

func join_lobby(this_lobby_id: int, _this_steam_id: int) -> void:
	Steam.joinLobby(this_lobby_id)

func leave_lobby() -> void:
	Steam.leaveLobby(lobby_id)
	lobby_data = []
	change_detected = true

func _on_lobby_chat_update(this_lobby_id: int, _changed_id: int, _making_change_id: int, _chat_state: int) -> void:
	print(_chat_state)
	get_lobby_data(this_lobby_id)

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
		Steam.initRelayNetworkAccess()
		set_user_variables()
	else:
		push_error("Steam couldn't connect succesfully - ", response)
