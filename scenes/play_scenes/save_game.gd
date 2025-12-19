extends Button

@onready var game_controller = get_node("/root/GameController")
@onready var label = $"../CashDisplay/Label"
@onready var player = $"../../Player"

var config = ConfigFile.new()

func save():
	config.set_value("cash", "value", game_controller.player_cash)
	config.set_value("position_x", "coordinates", player.position.x)
	config.set_value("position_y", "coordinates", player.position.y)
	config.save("user://savegame.cfg")

func load_save():
	var game_save = config.load("user://savegame.cfg")
	if game_save == OK:
		game_controller.player_cash = config.get_value("cash", "value", 0)
		label.text = str(game_controller.player_cash)

		var x = config.get_value("position_x", "coordinates", 0)
		var y = config.get_value("position_y", "coordinates", 0)
		player.position = Vector2(x, y)
