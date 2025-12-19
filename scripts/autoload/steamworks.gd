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
var steam_initialized = false


func check_command_line() -> void:
	var these_arguments: Array = OS.get_cmdline_args()
	# There are arguments to process
	if these_arguments.size() > 0:
		# A Steam connection argument exists
		if these_arguments[0] == "+connect_lobby":
			# Lobby invite exists so try to connect to it
			if int(these_arguments[1]) > 0:
				# At this point, you'll probably want to change scenes
				# Something like a loading into lobby screen
				print("Command line lobby ID: %s" % these_arguments[1])
				join_lobby(int(these_arguments[1]))

#region built in lobby signals
func _on_lobby_created(this_connect: int, this_lobby_id: int) -> void:
	if this_connect == 1:
		lobby_id = this_lobby_id
		print("Created lobby: ", lobby_id)
		Steam.setLobbyJoinable(lobby_id, true) # should be done by default, its here just in case
		Steam.setLobbyData(lobby_id, 'name', String(Steam.getPersonaName() + "'s lobby"))
		Steam.setLobbyData(lobby_id, 'description', "godotsteam test") # lobby data
		var set_relay: bool = Steam.allowP2PPacketRelay(true) #allow p2p fallback through steam if needed
		print("Allowing Steam to be relay backup: %s" % set_relay)

func _on_lobby_chat_update(_this_lobby_id: int, ) -> void:
	print("chat update")

func _on_lobby_join_requested(this_lobby_id: int, friend_id: int) -> void:
	var owner_name = Steam.getFriendPersonaName(friend_id)
	print("joining %s's lobby" % owner_name)
	join_lobby(this_lobby_id)
func _on_lobby_data_update(_success: int, _lobby_id: int, _member_id: int) -> void:
	print("lobby data updated")

func _on_lobby_invite() -> void:
	print("lobby invite")

func _on_lobby_joined(this_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	print("lobby joined %s" % this_lobby_id)
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		lobby_id = this_lobby_id
		get_lobby_members()
		make_p2p_handshake()
	else:
		var fail_reason: String
		match response:
			Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST: fail_reason = "This lobby no longer exists."
			Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED: fail_reason = "You don't have permission to join this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_FULL: fail_reason = "The lobby is now full."
			Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR: fail_reason = "Uh... something unexpected happened!"
			Steam.CHAT_ROOM_ENTER_RESPONSE_BANNED: fail_reason = "You are banned from this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED: fail_reason = "You cannot join due to having a limited account."
			Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED: fail_reason = "This lobby is locked or disabled."
			Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN: fail_reason = "This lobby is community locked."
			Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU: fail_reason = "A user in the lobby has blocked you from joining."
			Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER: fail_reason = "A user you have blocked is in the lobby."
		print("Failed to join this chat room: %s" % fail_reason)

func _on_lobby_message() -> void:
	print("lobby message")

func _on_persona_change(this_steam_id: int, _flag: int) -> void:
	if lobby_id > 0:
		print("A user (%s) had information change, update the lobby list" % this_steam_id)
		print(_flag)
		get_lobby_members()

func _on_p2p_session_request(remote_steam_id: int) -> void:
	print("p2p session request: ", remote_steam_id)

func _on_p2p_session_connect_fail(remote_steam_id: int, session_error: int) -> void:
	print("fasz", remote_steam_id, session_error)

#endregion

#region other lobby functions

func create_lobby() -> void:
	if lobby_id == 0:
		Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, 4)

func join_lobby(this_lobby_id: int) -> void:
	print("attempting to join lobby %s" % lobby_id)
	lobby_members.clear()
	Steam.joinLobby(this_lobby_id)

func get_lobby_members() -> void:
	lobby_members.clear()
	var num_of_members: int = Steam.getNumLobbyMembers(lobby_id)
	for this_member in range(0, num_of_members):
		var member_steam_id: int = Steam.getLobbyMemberByIndex(lobby_id, this_member)
		var member_steam_name = Steam.getFriendPersonaName(member_steam_id)
		lobby_members.append({"steam_id": member_steam_id, "steam_name": member_steam_name})

func read_p2p_packet() -> void:
	var packet_size: int = Steam.getAvailableP2PPacketSize(0)
	if packet_size > 0:
		var this_packet: Dictionary = Steam.readP2PPacket(packet_size, 0)
		if this_packet.is_empty() or this_packet == null:
			print("WARNING: read an empty packet with non-zero size!")
		var packet_sender: int = this_packet['remote_steam_id']
		var packet_code : PackedByteArray = this_packet['data']
		var readable_data: Dictionary = bytes_to_var(packet_code)
		print("Packets: %s, \n\npacket sender: %s" % readable_data, packet_sender)

func read_all_p2p_packets(read_count: int = 0):
	if read_count >= PACKET_READ_LIMIT:
		return
	if Steam.getAvailableP2PPacketSize(0) > 0:
		read_p2p_packet()
		read_all_p2p_packets(read_count + 1)

func make_p2p_handshake() -> void:
	print("Sending P2P handshake to lobby")
	Steam.sendP2PPacket(lobby_id, var_to_bytes("test"), Steam.P2P_SEND_RELIABLE)
	#send_p2p_packet(0, {"message": "handshake", "from": steam_id})

func send_p2p_packet(this_steam_id: int, data: PackedByteArray, send_type: int = Steam.P2P_SEND_RELIABLE, channel: int = 0):
	return Steam.sendP2PPacket(this_steam_id, data, send_type, channel)
#endregion


func _on_loaded_avatar(_user_id : int, avatar_size : int, avatar_buffer : PackedByteArray) -> void:
	var avatar_image : Image = Image.create_from_data(avatar_size, avatar_size, false, Image.FORMAT_RGBA8, avatar_buffer)
	avatar_image.resize(48, 48, Image.INTERPOLATE_LANCZOS)
	steam_image_texture = ImageTexture.create_from_image(avatar_image)
	menu_scene._successful_steam_connection() #also runs create_lobby

#this is like really bad code, because i should make a new scene for the lobby but ill do that once this works
func _process(_delta: float) -> void:
	Steam.run_callbacks()
	if lobby_id > 0:
		read_all_p2p_packets()

func set_user_variables() -> void:
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()
	Steam.getPlayerAvatar()
	Steam.avatar_loaded.connect(_on_loaded_avatar)
	steam_initialized = true
	
	Steam.join_requested.connect(_on_lobby_join_requested)
	#Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	Steam.p2p_session_request.connect(_on_p2p_session_request)
	Steam.p2p_session_connect_fail.connect(_on_p2p_session_connect_fail)
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_data_update.connect(_on_lobby_data_update)
	Steam.lobby_invite.connect(_on_lobby_invite)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_message.connect(_on_lobby_message)
	Steam.persona_state_change.connect(_on_persona_change)
	Steam.readP2PPacket(0, Steam.P2P_SEND_RELIABLE)
	check_command_line() #TODO scene path as argument


func _ready() -> void:
	menu_scene = get_tree().root.get_child(-1)
	var response = Steam.steamInitEx(480)
	if response.status == 0:
		print("steam connected succesfully")
		set_user_variables()
	else:
		push_error("Steam couldn't connect succesfully - ", response)
		menu_scene._no_steam_connection()
