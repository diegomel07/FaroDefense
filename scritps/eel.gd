extends CharacterBody2D

var health = 100
var damage = 1000
var original_speed = 100
var speed = original_speed
var target = Vector2(640,360)
var current_attraction_force = 0
var damage_interval = 2.0
var is_paralyzed = false


@onready var paralyze_timer = $ParalyzeTimer
@onready var detector = $RayCast2D
@onready var agent = $NavigationAgent2D

signal muerto


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


var damage_time = 0.0
var direction
func _physics_process(delta):
	# Movimiento
	agent.target_position = target
	direction = agent.get_next_path_position() - global_position
	direction = direction.normalized()
	velocity = direction * speed

	if position.distance_to(target) > 20:
		move_and_slide()
	
	look_at(target)
	rotate(-PI/2)
	
	if detector.collide_with_bodies:
		var faro = detector.get_collider()
		if faro and faro.has_method('faro_taking_damage'):
			damage_time += delta
			if damage_time >= damage_interval:
				aplly_damage(faro)
				damage_time = 0.0


func flip_sprite(x_direction):
	var sprite = $AnimatedSprite2D  # Asegúrate que sea el nodo correcto

	if abs(x_direction) > 0.1:
		sprite.flip_h = x_direction < 0




var faro_health = 0
func aplly_damage(faro):
	faro_health = faro.faro_discharge(damage)

func take_damage(cantidad):
	health -= cantidad
	if health <= 0:
		muerto.emit()
		queue_free()

func _on_enters_zone(enemy, body, faro_position, attraction_force):
	if enemy == self:
		if attraction_force > current_attraction_force:
			current_attraction_force = attraction_force
			target = faro_position

func paralyze(seconds: float):
	if is_paralyzed:
		return  # ya está paralizado
	is_paralyzed = true
	speed = 0  # Detener movimiento
	paralyze_timer.wait_time = seconds
	paralyze_timer.start()

func _on_paralyze_timer_timeout():
	is_paralyzed = false
	speed = original_speed  # Restaurar velocidad
