extends StaticBody2D

var enemies_inside = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $Deteccion.visible:
		apply_paralyze()

func apply_paralyze():
	for enemy in enemies_inside.keys():
		if is_instance_valid(enemy):
			enemy.paralyze(3)
			queue_free()


# si un intruso entra a la luz
func _on_light_body_entered(body):
	if body.has_method("paralyze"):
		enemies_inside[body] = true

func _on_light_body_exited(body):
	pass # Replace with function body.
