extends Control


@onready var label = $Label

func _ready():
	EventController.connect("health_changed", on_event_health_changed)
	
func on_event_health_changed(value: int) -> void:
	label.text = str(value)
