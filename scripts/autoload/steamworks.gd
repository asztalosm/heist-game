extends Node
#this is the script that handles lobbies

const PACKET_READ_LIMIT : int = 32
var lobby_data
var lobby_id: int = 0
var lobby_members: Array = []
var lobby_members_max: int = 10
var lobby_vote_kick: bool = false
var steam_id: int = 0
var steam_username: String = ""
var steam_image_texture : ImageTexture
var menu_scene

func _on_loaded_avatar(_user_id : int, avatar_size : int, avatar_buffer : PackedByteArray) -> void:
	var avatar_image : Image = Image.create_from_data(avatar_size, avatar_size, false, Image.FORMAT_RGBA8, avatar_buffer)
	avatar_image.resize(48, 48, Image.INTERPOLATE_LANCZOS)
	steam_image_texture = ImageTexture.create_from_image(avatar_image)
	menu_scene._successful_steam_connection()
#this is like really bad code, because i should make a new scene for the lobby but ill do that once this works
func _process(_delta: float) -> void:
	Steam.run_callbacks()

func set_user_variables() -> void:
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()
	Steam.getPlayerAvatar()
	Steam.avatar_loaded.connect(_on_loaded_avatar)

func _ready() -> void:
	menu_scene = get_tree().root.get_child(-1)
	var response = Steam.steamInitEx(480)
	if response.status == 0:
		print("steam connected succesfully")
		set_user_variables()
	else:
		push_error("Steam couldn't connect succesfully - ", response)
		menu_scene._no_steam_connection()
