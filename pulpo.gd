extends CharacterBody2D
@onready var bullet_scene = preload("res://Bala.tscn")
@onready var shoot_timer = $Timer

func _ready():
	shoot_timer.start()

func _on_Timer_timeout():
	var num_bullets = 12  # por ejemplo
	var angle_step = 360 / num_bullets
	for i in range(num_bullets):
		var angle = deg2rad(i * angle_step)
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.rotation = angle
		bullet.set_velocity(angle)  # función en la bala
		get_tree().current_scene.add_child(bullet)
