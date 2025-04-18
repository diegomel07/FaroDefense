extends CharacterBody2D

var health = 100
var damage = 20
var speed = 100
var target = Vector2(640,360)
var current_attraction_force = 0
var damage_interval = 2.0


@onready var detector = $RayCast2D
@onready var agent = $NavigationAgent2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


var damage_time = 0.0
var direction
func _physics_process(delta):
	agent.target_position = target
	direction = agent.get_next_path_position() - global_position
	direction = direction.normalized()
	velocity = direction * speed
	
	# look_at(target)
	if position.distance_to(target) > 20:
		move_and_slide()
		
	look_at(target)
	
	if detector.collide_with_bodies:
		var faro = detector.get_collider()
		if faro and faro.has_method('faro_taking_damage'):
			damage_time += delta
			if damage_time >= damage_interval:
				aplly_damage(faro)
				damage_time = 0.0

var faro_health = 0
func aplly_damage(faro):
	faro_health = faro.faro_taking_damage(damage)
	if faro_health < 1:
		target = Vector2(640,360)
		current_attraction_force = 0

func take_damage(cantidad):
	health -= cantidad
	if health <= 0:
		queue_free()

func _on_enters_zone(enemy, body, faro_position, attraction_force):
	if enemy == self:
		if attraction_force > current_attraction_force:
			current_attraction_force = attraction_force
			target = faro_position

