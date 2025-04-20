extends CharacterBody2D

var health = 100
var damage = 40
var damage_radius = 5
var attraction_radius = 100
@export var attraction_force = 100
var cant_energy = 100
var light_cost = 10
var enemies_inside = {}
var damage_interval = 1.0  # cada 1 segundo

@export var velocidad = 100
var can_move = false

@onready var light_timer := $LightTimer  # Timer en la escena
@onready var attraction_sprite := $AttractionArea/Sprite2D
@onready var attraction_collision := $AttractionArea/CollisionShape2D
@onready var circle = attraction_collision.shape
@onready var slider = $HSlider
signal enemy_enters(enemy, body, faro_position, attraction_force)

# Called when the node enters the scene tree for the first time.
func _ready():
	slider.value = cant_energy
	adjust_attraction_area_size(attraction_radius)

# Called every frame. 'delta' is the elapsed time since the previous frame.
var damage_time = 0.0
func _process(delta):
	slider.value = cant_energy
	if $Light2.enabled:
		damage_time += delta
		if damage_time >= damage_interval:
			aplly_damage()
			damage_time = 0.0
	if Input.is_action_just_pressed("movement"):
		can_move = true
func _physics_process(delta):
	if can_move:
		var input_vector = Vector2.ZERO
		if Input.is_action_pressed("ui_right"):
			input_vector.x += 1
		if Input.is_action_pressed("ui_left"):
			input_vector.x -= 1
		if Input.is_action_pressed("ui_down"):
			input_vector.y += 1
		if Input.is_action_pressed("ui_up"):
			input_vector.y -= 1
		input_vector = input_vector.normalized()
		velocity = input_vector * velocidad
		move_and_slide()
		
func aplly_damage():
	for enemy in enemies_inside.keys():
		if is_instance_valid(enemy):
			enemy.take_damage(damage)

func adjust_attraction_area_size(size):
	# Escalamos el Sprite2D
	var texture_size = attraction_sprite.texture.get_size()
	var scale_factor = size / max(texture_size.x, texture_size.y)
	attraction_sprite.scale = Vector2.ONE * scale_factor

	# Ajustamos el radio del círculo
	circle.radius = size / 2.0

func _on_input_event(viewport, event, shape_idx):
	if event.is_pressed():
		$Light2.enabled = !$Light2.enabled  # Alternar luz
		$Light/CollisionShape2D.disabled = !$Light2.enabled
		if $Light2.enabled:
			$AnimatedSprite2D.play('light_on')
		else:
			$AnimatedSprite2D.stop()
		
		$AttractionArea.visible = !$AttractionArea.visible  # Alternar luz
		$AttractionArea/CollisionShape2D.disabled = !$AttractionArea.visible  # Alternar luz
		
		if $Light2.enabled:
			light_timer.wait_time = 2.0
			light_timer.start()
		else:
			#print("Luz apagada")
			light_timer.wait_time = 1.0
			light_timer.start()

# si un intruso entra a la luz
func _on_light_body_entered(body):
	if body.name != "faro" and body.has_method("take_damage"):
		enemies_inside[body] = true

func _on_light_body_exited(body):
	pass # Replace with function body.

# se recarga o carga la energia
func _on_light_timer_timeout():
	if $Light2.enabled:
		cant_energy -= light_cost
		#print("Energía:", cant_energy)
		if cant_energy <= 0:
			cant_energy = 0
			$Light2.enabled = false  # Apagar luz si se agota energía
			$Light/CollisionShape2D.disabled = false  
			$AttractionArea.visible = false
			$AttractionArea/CollisionShape2D.disabled = false
			#print("¡Energía agotada! Luz apagada.")
			light_timer.wait_time = 1.0  # Cambiar a modo recarga
	else:
		if cant_energy < 100:
			cant_energy += 10
			#print("Recargando... Energía:", cant_energy)
		if cant_energy >= 100:
			cant_energy = 100
			light_timer.stop()
			#print("Energía recargada por completo.")

func _on_attraction_area_body_entered(body):
	if body.name != 'faro':
		enemy_enters.emit(body, self, position, attraction_force)

func _on_attraction_area_body_exited(body):
	pass

func faro_taking_damage(cantidad):
	health -= cantidad
	if health <= 0:
		queue_free()
	return health

func faro_discharge(cantidad):
	cant_energy -= cantidad
	if cant_energy <= 0:
		cant_energy = 0
		$Light2.enabled = false  # Apagar luz
		$Light/CollisionShape2D.disabled = false
		$AttractionArea.visible = false
		$AttractionArea/CollisionShape2D.disabled = false
		light_timer.wait_time = 1.0  # Cambiar a modo recarga
		light_timer.start()


func _on_enemigo_muerto():
	print('muerto')

func activate_movement():
	can_move = true
