extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_canvas_modulate_time_tick(day, hour, minute):
	text = 'Día ' + str(day) + ' Hora: ' + str(hour) + ' Minutos: '  + str(minute)
	#if hour >= 0 and hour < 6:
		#text = 'Día ' + str(day) + ' Hora: ' + str(hour) + ' Minutos: '  + str(minute)
	#else:
		#text = 'Día ' + str(day)
