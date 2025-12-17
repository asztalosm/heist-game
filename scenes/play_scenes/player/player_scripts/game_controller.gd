extends Node

var player_cash = 0

func cash_collected(value: int):
	player_cash += value
	EventController.emit_signal("cash_collected", player_cash)
