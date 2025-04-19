extends CanvasLayer

@onready var inventory = $inventory

func _ready():
	inventory.close()

func _on_button_2_pressed():
	if inventory.is_open:
		inventory.close()
	else:
		inventory.open()

