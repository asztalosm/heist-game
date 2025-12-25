extends CharacterBody2D
var health = 100
var speed = 100
var chasing_player = false
var player = null
var Bullet = preload("res://scenes/objects/bullet.tscn")
var seconds = 1
var can_shoot = true

func _physics_process(delta: float) -> void:
	if chasing_player:
		var distance = position.distance_to(player.position)
		rotate(get_angle_to(player.position) + 0.5 * PI)
		if distance > 200:
			var direction = (player.position - position).normalized()
			velocity = direction * speed
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			shoot_at_player()
		
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
		
func shoot_at_player():
	if not can_shoot:
		return

	can_shoot = false
	var bullet = Bullet.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_transform = $Muzzle.global_transform
	await get_tree().create_timer(1.0).timeout
	can_shoot = true
