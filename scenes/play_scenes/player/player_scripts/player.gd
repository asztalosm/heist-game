class_name Player extends CharacterBody2D

@onready var player = $"."
const SPEED = 300

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction:
		velocity = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	rotate(get_angle_to(get_global_mouse_position()) + 0.5 * PI)
	move_and_slide()
	
