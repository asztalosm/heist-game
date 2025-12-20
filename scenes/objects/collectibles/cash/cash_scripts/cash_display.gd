extends Control

@onready var label = $Label

func _ready():
	EventController.connect("cash_collected", on_event_cash_collected)
	
func on_event_cash_collected(value: int) -> void:
	label.text = str(value)
