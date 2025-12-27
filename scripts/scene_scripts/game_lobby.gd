extends Node2D
func play_singleplayer() -> void:
	print("sp")

func play_multiplayer() -> void:
	print("mp")

func _ready() -> void:
	if Steamworks.lobby_data == []:
		print("lobby data unavailable - player has no steam connection or didn't make lobby")
		play_singleplayer()
	else:
		print("lobby data unavailabl")
		play_multiplayer()



#func _process(delta: float) -> void:
#	pass
