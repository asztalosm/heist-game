extends Node

var player_cash = 0
var player_health = 100

func cash_collected(value: int):
	player_cash += value
	EventController.emit_signal("cash_collected", player_cash)

func take_damage(value: int):
	player_health -= value
	EventController.emit_signal("health_changed", player_health)
	#ez majd később multiplayernél seggbe fog harapni szerintem de reméljük hogy nem
