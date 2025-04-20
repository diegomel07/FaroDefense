extends CanvasModulate


# 6 a 6 y que esas 6 horas duren 6 minutos 
# ciclo de 24 horas de 12 minutos 720 segundos INGAME_SPEED = 2
enum EstadoJuego { PAUSADO, JUGANDO, AVANCE_RAPIDO, TUTORIAL }
var estado = EstadoJuego.PAUSADO

const MINUTES_PER_DAY = 1440
const MINUTES_PER_HOUR = 60
const INGAME_TO_REAL_MINUTE_DURATION = (2 * PI) / MINUTES_PER_DAY


signal time_tick(day:int, hour:int, minute:int)
signal dia_nuevo()
signal lose()


@export var gradient_texture:GradientTexture1D
@export var INGAME_SPEED = 2
@export var INITIAL_HOUR = 6:
	

	set(h):
		INITIAL_HOUR = h
		time = INGAME_TO_REAL_MINUTE_DURATION * MINUTES_PER_HOUR * INITIAL_HOUR


var time:float= 0.0
var past_minute:int= -1


func _ready() -> void:
	time = INGAME_TO_REAL_MINUTE_DURATION * MINUTES_PER_HOUR * INITIAL_HOUR
	var value = (sin(time - PI / 2.0) + 1.0) / 2.0
	self.color = gradient_texture.gradient.sample(value)


func _process(delta: float) -> void:
		
	print(estado)
	if estado == EstadoJuego.TUTORIAL:
		$"../CanvasLayer/play".visible = true
		$"../CanvasLayer/shop".visible = true

		$"../CanvasLayer/Button".visible = true
		$"../CanvasLayer/Button2".visible = true
	if estado != EstadoJuego.PAUSADO:
		$"../CanvasLayer/Button".visible = false
		$"../CanvasLayer/Button2".visible = false
		$"../CanvasLayer/play".visible = false
		$"../CanvasLayer/shop".visible = false
		time += delta * INGAME_TO_REAL_MINUTE_DURATION * INGAME_SPEED
		var value = (sin(time - PI / 2.0) + 1.0) / 2.0
		self.color = gradient_texture.gradient.sample(value)
		_recalculate_time()
	else:
		$"../CanvasLayer/Button".visible = true
		$"../CanvasLayer/Button2".visible = true
		$"../CanvasLayer/play".visible = true
		$"../CanvasLayer/shop".visible = true


func _recalculate_time() -> void:
	var total_minutes = int(time / INGAME_TO_REAL_MINUTE_DURATION)
	
	var day = int(total_minutes / MINUTES_PER_DAY)
	var current_day_minutes = total_minutes % MINUTES_PER_DAY
	var hour = int(current_day_minutes / MINUTES_PER_HOUR)
	var minute = int(current_day_minutes % MINUTES_PER_HOUR)

	# Emitir tick de tiempo
	if past_minute != minute:
		past_minute = minute
		time_tick.emit(day, hour, minute)

	# Si está en fase de juego (0h a 6h) y llega a 6 AM
	if estado == EstadoJuego.JUGANDO and hour == 6:
		estado = EstadoJuego.PAUSADO
		dia_nuevo.emit()

	# Si está en avance rápido y vuelve a las 0 AM
	if estado == EstadoJuego.AVANCE_RAPIDO and hour == 0:
		estado = EstadoJuego.JUGANDO
		INGAME_SPEED = 2

	# Perder al día 3
	if day == 3:
		lose.emit()

func _on_button_pressed():
	if estado == EstadoJuego.PAUSADO:
		estado = EstadoJuego.AVANCE_RAPIDO
		INGAME_SPEED = 100
