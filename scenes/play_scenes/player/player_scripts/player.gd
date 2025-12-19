class_name Player extends CharacterBody2D

@onready var player = $"."
@onready var sprite = $Sprite2D
const SPEED = 300
var pistol_in_hand = false
var player_sprite = preload("res://resources/textures/sprites/idle.png")
var player_pistol_sprite = preload("res://images/icon.jpg")

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction:
		velocity = direction.rotated((get_global_mouse_position() - global_position).angle() + 0.5 * PI) * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	rotate(get_angle_to(get_global_mouse_position()) + 0.5 * PI)
	move_and_slide()
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("switch_to_pistol"):
		if pistol_in_hand == false:
			pistol_in_hand = true
			sprite.texture = player_pistol_sprite
		else:
			sprite.texture = player_sprite
			pistol_in_hand = false
