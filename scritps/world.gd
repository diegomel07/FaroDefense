extends Node2D
enum EstadoJuego { PAUSADO, JUGANDO, AVANCE_RAPIDO }
var map_width = 1280
var map_height = 720
var enemy_preload = preload("res://scenes/enemigo.tscn")
var eel = preload("res://scenes/eel.tscn")
var shark = preload("res://scenes/tiburon.tscn")
var map_rect = Rect2(Vector2.ZERO, Vector2(map_width, map_height))

var tuto = true
@onready var faros = $NavigationRegion2D/Faros.get_children()
@onready var enemies_abisal = $EnemiesAbisal
@onready var audio_player = $AudioStreamPlayer2D

@onready var dialogue_box = $CanvasLayer/DialogueBox
# Stats Jugador
var puntos = 9999999
var death = false
func _ready():
	$CanvasModulate.estado = $CanvasModulate.EstadoJuego.TUTORIAL 
	start_tutorial()
	pass
	
var tutorial_step := 0

func start_tutorial():
	tutorial_step = 0
	show_next_tutorial_step()

func show_next_tutorial_step():
	match tutorial_step:
		0:
			dialogue_box.texts = [
				"¿Pero qué tenemos aquí? El nuevo recluta ha llegado antes de lo esperado.",
				"¿Qué te ha hecho pensar que este es un trabajo fácil, eh, hijo?",
				"Aquí no llega nunca nadie, jeje.",
				"Excepto... ellos.",
				"¿Que quiénes son? Verás, en los rincones más recónditos de este mar ",
				"se esconden las bestias más feroces.",
				"Es mi trabajo defender este faro con los fogonazos que emite.",
				"La niebla se traga los gritos, pero la luz lo atraviesa todo.",
				"Este ahora también es tu trabajo."
			]
			dialogue_box.current_text_index = 0
			dialogue_box.show_text()
		
		1:
			dialogue_box.texts = [
				"Empieza colocando una boya para distraer a las bestias,",
				"y que el rango de su luz les haga daño a través del tiempo"
			]
			dialogue_box.current_text_index = 0
			dialogue_box.show_text()

		2:
			$CanvasLayer/inventory.open()
		3:
			$CanvasLayer/inventory.close()
			dialogue_box.texts = [
				"Es tu deber administrar la luz de tus boyas. La luz no dura eternamente.",
				"Mientras se mantenga encendida, las bestias se verán atraídas a su luz.",
				"Cada noche ganarás más recursos para colocar más boyas y otros objetos que te serán de utilidad.",
				"Como las murallas: muros de gran solidez que nadie es capaz de atravesar.",
				"También tenemos viejas trampas de pesca. Todavía funcionan, pero solo logran paralizar a las bestias por un breve instante.",
				"Ahora es momento de esperar al anochecer.",
				"Mucha suerte, chico. La vas a necesitar."
			]
			dialogue_box.current_text_index = 0
			dialogue_box.show_text()
			tuto = false
			


						
func _process(delta):

	if $NavigationRegion2D/Faros.get_child_count() > 1 and tuto == true:
		tutorial_step+=1
		show_next_tutorial_step()
		
	$CanvasLayer/Control2/puntos.text = 'Puntos: ' + str(puntos) 
	if !is_instance_valid($NavigationRegion2D/Faros/faro) and death == false:
		death = true
		$CanvasModulate.estado = $CanvasModulate.EstadoJuego.TUTORIAL 
		var dialogs =  [
		"Como solía decir mi abuela: ‘Lorem ipsum dolor sit amet, consectetur adipiscing elit..",
		"Un faro no elige cuándo brillar.",
		"La luz nunca duerme, ni yo tampoco."
		]
		dialogue_box.texts= [dialogs[random_number(0,len(dialogs)-1)]]
		dialogue_box.show_text()
		dialogue_box.current_text_index = 0

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


func generate_enemies(cant_enemies: int, prob1: float, prob2: float, prob3: float):
	var total_prob = prob1 + prob2 + prob3
	if total_prob == 0:
		push_warning("Las probabilidades no pueden ser 0.")
		return

	# Normalizamos las probabilidades en caso de que no sumen exactamente 1
	prob1 /= total_prob
	prob2 /= total_prob
	prob3 /= total_prob

	for i in range(cant_enemies):
		var roll = randf()

		var selected_scene: PackedScene
		if roll < prob1:
			selected_scene = enemy_preload
		elif roll < prob1 + prob2:
			selected_scene = eel
		else:
			selected_scene = shark

		var enemy = selected_scene.instantiate()
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
	print("nuevo dia")
	var dialogs = [
	"La noche se va, pero no te confíes... siempre vuelve.",
	"Sobreviviste... esta vez.",
	"La luz ganó por ahora. Pero las sombras aprenden rápido.",
	"Buen trabajo. Aunque aquí, el amanecer nunca es garantía.",
	"Lo lograste. Pero cada noche los rugidos suenan más cerca.",
	"El faro sigue en pie... gracias a ti."
	]
	dialogue_box.texts= [dialogs[random_number(0,len(dialogs)-1)]]
	dialogue_box.current_text_index = random_number(0,len(dialogue_box.texts)-1)
	dialogue_box.show_text()
	dialogue_box.current_text_index = 0

func load_mp3(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var sound = AudioStream.new()
	sound.data = file.get_buffer(file.get_length())
	return sound


func _on_canvas_modulate_time_tick(day, hour, minute):
	
	if hour == 6:
		if !audio_player.stream == preload("res://assets/music/chill.mp3"):
			audio_player.stream = preload("res://assets/music/chill.mp3")
			audio_player.play()
			audio_player.stream.loop = true
			$GPUParticles2D.visible = false
			eliminar_enemigos()
	
	# apenas sean las 12 am - 0
	
	# Se ejecuta solo de 0h a 6h
	# Solo durante la noche
	if hour >= 0 and hour < 6:
		if audio_player.stream == preload("res://assets/music/chill.mp3"):
			audio_player.stream = preload("res://assets/music/IN Stage 4 (powerful) Boss - Marisa Kirisame's Theme - Love-colored Master Spark [_6L6E7TLy10].mp3")
			audio_player.play()
			audio_player.stream.loop = true
		$GPUParticles2D.visible = true
		var minutes_passed = hour * 60 + minute
		# Oleadas cada 30 minutos (solo 2 por noche)
		if minutes_passed % 30 == 0:
			var wave = int(minutes_passed / 30)  # 0, 1, 2

			# Cantidad base por oleada: empieza bajo y crece muy lento
			var base_count = clamp(1 + int(day / 3) + int(wave), 1, 6)

			match day:
				1:
					generate_enemies(base_count, 1.0, 0.0, 0.0)
				2:
					var p2 = clamp(wave * 0.2, 0.0, 0.3)
					var p1 = 1.0 - p2
					generate_enemies(base_count, p1, p2, 0.0)
				3:
					var p3 = clamp(wave * 0.1, 0.0, 0.3)
					var p2 = clamp(wave * 0.2, 0.0, 0.4)
					var p1 = max(0.0, 1.0 - p2 - p3)
					generate_enemies(base_count, p1, p2, p3)
				_:
					var p3 = clamp((wave + day) * 0.02, 0.1, 0.5)
					var p2 = clamp((wave + day) * 0.03, 0.2, 0.5)
					var p1 = max(0.0, 1.0 - p2 - p3)
					generate_enemies(base_count, p1, p2, p3)



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
	
func random_number(min, max):
	return randi_range(min, max)


func _on_dialogue_box_dialogue_finished():
	tutorial_step += 1
	if tutorial_step == 4:
		$CanvasModulate.estado = $CanvasModulate.EstadoJuego.PAUSADO 
	if death == true: 
		print("muerte")
		get_tree().quit()	
	show_next_tutorial_step()
