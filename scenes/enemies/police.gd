extends CharacterBody2D
var health = 100
var speed = 100
var chasing_player = false
var player = null

func _physics_process(delta: float) -> void:
	if chasing_player:
		var direction = (player.position - position).normalized()
		velocity = direction * speed
		move_and_slide()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		health -= 20
		$ProgressBar.value = health
		area.queue_free()
		
		if health <= 0:
			queue_free()

func _on_enemy_radius_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("player"):
		chasing_player = true
		player = body
	
func _on_enemy_radius_body_exited(body: CharacterBody2D) -> void:
	if body.is_in_group("player"):
		chasing_player = false
		player = body
