extends Node2D

var lobby_id = null
var host_id = 0
var max_members = 2
var lobby_members = []
var steam_id
var steam_username
const PACKET_READ_LIMIT = 32
var is_host


func _ready():
	print("STEAM INIT:", Steam.isSteamRunning()) 
	print("APPID:", Steam.getAppID())
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.p2p_session_request.connect(_on_p2p_session_request)
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()

func _process(delta):
	if lobby_id != null:
		read_all_p2p_packets()

func _create_lobby() -> void:
	if lobby_id == 0:
		is_host = true
		Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, max_members)

func _on_join_lobby_pressed():
	var id_to_join = int($TextEdit.text.strip_edges())
	Steam.joinLobby(id_to_join)

func _on_lobby_created(success, id):
	if not success:
		return

	lobby_id = id
	Steam.setLobbyData(lobby_id, "name", Steam.getPersonaName() + "'s lobby")
	Steam.setLobbyJoinable(lobby_id, true)
	Steam.allowP2PPacketRelay(true)
	Steam.setLobbyMemberData(lobby_id, "ready", "0")
	print(lobby_id)

func _on_lobby_joined(_lobby_id: int, _permission: int, _locked: bool, response: int):
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		print("siker")
		self.lobby_id = lobby_id
		get_lobby_members()
		make_p2p_handshake()
		print(lobby_members)
		if Steam.getLobbyOwner(lobby_id) == steam_id:
			$P1Name.text = "owner: " + Steam.getPersonaName()
		else:
			if lobby_members.size() > 1:
				$P2Name.text = lobby_members[1]["steam_name"]
		$CreateLobby.hide()
		$JoinLobby.hide()
		$TextEdit.hide()
		print(lobby_id)
	else:
		# Get the failure reason
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


func get_lobby_members():
	lobby_members.clear()
	var num = Steam.getNumLobbyMembers(lobby_id)
	print("number of players in lobby: ", num)
	for member in range(num):
		var id = Steam.getLobbyMemberByIndex(lobby_id, member)
		var name = Steam.getFriendPersonaName(id)
		lobby_members.append({"steam_id": id, "steam_name": name})

func send_p2p_packet(this_target: int, packet_data: Dictionary, send_type: int = 0):
	var channel = 0
	var this_data: PackedByteArray
	this_data.append_array(var_to_bytes(packet_data))

	if this_target == 0:
		if lobby_members.size() > 1:
			for member in lobby_members:
				if member["steam_id"] != steam_id:
					Steam.sendP2PPacket(member["steam_id"], this_data, send_type, channel)
	else:
		Steam.sendP2PPacket(this_target, this_data, send_type, channel)

func _on_p2p_session_request(remote_id):
	Steam.acceptP2PSessionWithUser(remote_id)

func make_p2p_handshake():
	send_p2p_packet(0, {"message": "handshake", "steam_id": steam_id, "username": steam_username})

func read_all_p2p_packets(read_count = 0):
	if read_count >= PACKET_READ_LIMIT:
		return

	if Steam.getAvailableP2PPacketSize(0) > 0:
		read_p2p_packet()
		read_all_p2p_packets(read_count + 1)

func read_p2p_packet():
	var packet_size = Steam.getAvailableP2PPacketSize(0)

	if packet_size > 0:
		var this_packet: Dictionary = Steam.readP2PPacket(packet_size, 0)
		var packet_sender: int = this_packet["remote_steam_id"]
		var packet_code: PackedByteArray = this_packet["data"]
		var readable_data: Dictionary = bytes_to_var(packet_code)

		if readable_data.has("message"):
			match readable_data["message"]:
				"handshake":
					print("PLAYER: ", readable_data["username"], "HAS JOINED")
					get_lobby_members()
