extends Node2D
var speed = 150
var direction = Vector2.ZERO

func set_velocity(angle):
	direction = Vector2(cos(angle), sin(angle))

func _process(delta):
	position += direction * speed * delta
