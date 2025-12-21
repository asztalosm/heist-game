extends Area2D

var speed = 750
const DAMAGE = 20

func _ready():
	add_to_group("bullet")

func _physics_process(delta):
	position += transform.x * speed * delta
