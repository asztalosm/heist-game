extends Node

var steam_id = 0
var steam_username = ""

func _ready():
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()
