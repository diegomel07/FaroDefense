extends Node2D

var map_width = 1280
var map_height = 720
var enemy_preload = preload("res://scenes/enemigo.tscn")
var eel = preload("res://scenes/eel.tscn")
var map_rect = Rect2(Vector2.ZERO, Vector2(map_width, map_height))


@onready var faros = $NavigationRegion2D/Faros.get_children()
@onready var enemies_abisal = $EnemiesAbisal

# Stats Jugador
var puntos = 2000

func _ready():
	pass


func _process(delta):
	$CanvasLayer/Control2/puntos.text = 'Puntos: ' + str(puntos) 


func get_spawn_position_outside_map() -> Vector2:
	var margin := 50  # Qué tan lejos fuera del mapa spawnean
	
	match randi() % 4:
		0: # Arriba
			return Vector2(
				randf_range(map_rect.position.x - margin, map_rect.end.x + margin),
				map_rect.position.y - margin
			)
		1: # Abajo
			return Vector2(
				randf_range(map_rect.position.x - margin, map_rect.end.x + margin),
				map_rect.end.y + margin
			)
		2: # Izquierda
			return Vector2(
				map_rect.position.x - margin,
				randf_range(map_rect.position.y - margin, map_rect.end.y + margin)
			)
		3: # Derecha
			return Vector2(
				map_rect.end.x + margin,
				randf_range(map_rect.position.y - margin, map_rect.end.y + margin)
			)
		_: 
			return Vector2.ZERO


func generate_enemies(cant_enemies):
	for i in range(cant_enemies):
		var enemy_scene: PackedScene
		var roll = randf()

		if roll < 0.0:
			enemy_scene = enemy_preload  # 70% de probabilidad
		else:
			enemy_scene = eel  # 30% de probabilidad

		var enemy = enemy_scene.instantiate()
		enemy.position = get_spawn_position_outside_map()

		connect_enemies_with_attraction(enemy)
		enemy.connect('muerto', Callable(self, "_on_enemigo_muerto"))

		enemies_abisal.add_child(enemy)


func connect_enemies_with_attraction(enemy):
	# Asumiendo que las zonas están bajo un nodo llamado "Zonas"
	for faro in faros:
		if is_instance_valid(faro) and faro.has_signal("enemy_enters"):
			faro.connect("enemy_enters", Callable(enemy, "_on_enters_zone"))

# CADA NUEVO DIA 6 AM
func _on_canvas_modulate_dia_nuevo():
	pass


func _on_canvas_modulate_time_tick(day, hour, minute):
	if hour == 6:
		eliminar_enemigos()
	
	# apenas sean las 12 am - 0
	
	#Distinguir entre dias para hacer nuevas ronda
	if hour >= 0 and hour <= 5:
		#tutorial
		if day == 1:
			if minute % 20 == 0:
				generate_enemies(3)
		
		if day == 2:
			if minute % 20 == 0:
				generate_enemies(3)
				
		if day == 3:
			if minute % 20 == 0:
				generate_enemies(3)
				
		if day == 4:
			if minute % 20 == 0:
				generate_enemies(3)
			

func eliminar_enemigos():
	for child in $EnemiesAbisal.get_children():
		child.queue_free()

func _on_enemigo_muerto():
	puntos += 100


func _on_inventory_closed():
	get_tree().paused = false


func _on_inventory_opened():
	$CanvasLayer/inventory.puntos_jugador = puntos
	get_tree().paused = true


func _on_button_pressed():
	$NavigationRegion2D.bake_navigation_polygon()
	faros = $NavigationRegion2D/Faros.get_children()


func _on_inventory_buy(precio):
	puntos = puntos - precio
