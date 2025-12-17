extends Node2D

@export var value: int = 200

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		GameController.cash_collected(value)
		self.queue_free()
