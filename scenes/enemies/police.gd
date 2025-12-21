extends CharacterBody2D
var health = 100

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		health -= 20
		$ProgressBar.value = health
		area.queue_free()
		
		if health <= 0:
			queue_free()
