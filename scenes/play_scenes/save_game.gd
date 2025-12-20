extends Button

@onready var game_controller = get_node("/root/GameController")
@onready var label = $"../CashDisplay/Label"
@onready var player = $"../../Player"

var config := ConfigFile.new()

func save():
	config.set_value("cash", "value", Marshalls.utf8_to_base64(str(game_controller.player_cash)))
	config.set_value("position_x", "coordinates", Marshalls.utf8_to_base64(str(player.position.x)))
	config.set_value("position_y", "coordinates", Marshalls.utf8_to_base64(str(player.position.y)))
	config.save("user://savegame.cfg")


func load_save():
	if config.load("user://savegame.cfg") != OK:
		return

	var cash_b64 = config.get_value("cash", "value", "")
	var x_b64 = config.get_value("position_x", "coordinates", "")
	var y_b64 = config.get_value("position_y", "coordinates", "")

	game_controller.player_cash = int(Marshalls.base64_to_utf8(cash_b64))

	label.text = str(game_controller.player_cash)

	player.position = Vector2(float(Marshalls.base64_to_utf8(x_b64)), float(Marshalls.base64_to_utf8(y_b64)))
