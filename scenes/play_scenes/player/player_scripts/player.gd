class_name Player extends CharacterBody2D

@onready var player = $"."
@onready var sprite = $Sprite2D
var Bullet : PackedScene = preload("res://scenes/objects/bullet.tscn")
const SPEED = 300
var pistol_in_hand = false
var player_sprite = preload("res://resources/textures/sprites/idle.png")
var player_pistol_sprite = preload("res://resources/textures/sprites/pistol.png")

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * SPEED
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
	if Input.is_action_just_pressed("fire"):
		fire()

func fire():
	if pistol_in_hand == true:
		var bullet = Bullet.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_transform = $Muzzle.global_transform

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		GameController.take_damage(20)
		print("-20 hp.")

		if GameController.player_health <= 0:
			queue_free()
