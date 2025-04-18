extends Node2D

var cant_enemies = 10
var map_width = 1280
var map_height = 720
var enemy_preload = preload("res://scenes/enemigo.tscn")
@onready var faros = $NavigationRegion2D/Faros.get_children()

func _ready():
	generate_enemies()


func generate_enemies():
	for i in range(cant_enemies):
		var enemy = enemy_preload.instantiate()
		# Posición aleatoria dentro del mapa
		var x = randi_range(0, map_width)
		var y = randi_range(0, map_height)
		enemy.position = Vector2(x, y)

		add_child(enemy)
		# Conectar este personaje con todas las zonas activas
		connect_enemies_with_attraction(enemy)

func connect_enemies_with_attraction(enemy):
	# Asumiendo que las zonas están bajo un nodo llamado "Zonas"
	for faro in faros:
		if faro.has_signal("enemy_enters"):
			faro.connect("enemy_enters", Callable(enemy, "_on_enters_zone"))


