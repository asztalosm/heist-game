extends Node2D

var being_robbed: bool = false
var near_vault: bool = false
var money = preload("res://scenes/objects/collectibles/cash/cash.tscn")

func _on_area_2d_body_entered(body) -> void:
	if body.is_in_group("player"):
		near_vault = true

func _on_area_2d_body_exited(body) -> void:
	if body.is_in_group("player"):
		near_vault = false
		being_robbed = false
		$Timer.stop()

func _physics_process(delta):
	if being_robbed and not Input.is_action_pressed("rob_vault"):
		being_robbed = false
		$Timer.stop()
		$ProgressBar.visible = false
		$ProgressBar.value = 0

	if being_robbed:
		$ProgressBar.visible = true
		$ProgressBar.max_value = $Timer.wait_time
		$ProgressBar.value = $Timer.wait_time - $Timer.time_left

func _process(delta):
	if near_vault:
		if Input.is_action_just_pressed("rob_vault") and not being_robbed:
			being_robbed = true
			$Timer.start()
			$ProgressBar.visible = true

func _on_timer_timeout():
	if being_robbed:
		being_robbed = false
		$ProgressBar.visible = false
		$ProgressBar.value = 0
		for i in range(0, 10):
			var cash = money.instantiate()
			var angle = randf() * TAU
			var distance = randf_range(60, 80)
			var offset = Vector2(cos(angle), sin(angle)) * distance
			get_tree().current_scene.add_child(cash)
			cash.global_position = global_position + offset
