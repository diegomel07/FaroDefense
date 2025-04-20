extends Control

signal opened
signal closed
signal buy(precio)

var is_open: bool = false
var puntos_jugador = 0
var colocable_escena


@onready var inventory: Inventory = preload("res://inventory/items/player_inventory.tres")
@onready var slots = $NinePatchRect/Inventory.get_children()
@onready var floating_item: TextureRect = $FloatingItem
var precio

func _ready():
	inventory.updated.connect(update)
	update()
	floating_item.visible = false
	floating_item.mouse_filter = Control.MOUSE_FILTER_IGNORE

func update():
	for i in range(min(inventory.slots.size(), slots.size())):
		slots[i].update(inventory.slots[i])

func _process(delta):
	if floating_item.visible:
		floating_item.global_position = get_global_mouse_position() - floating_item.size / 2

func open():
	update()
	visible = true
	is_open = true
	opened.emit()

func close():
	visible = false
	is_open = false
	closed.emit()

func _on_crafting_button_pressed():
	pass

func _on_slot_pressed():
	colocable_escena = preload("res://scenes/boya.tscn")
	var item_node = $NinePatchRect/Inventory/slot/CenterContainer/Panel/item
	if item_node and item_node.texture:
		floating_item.texture = item_node.texture
		floating_item.visible = true
		precio = int($NinePatchRect/Inventory/slot/CenterContainer/Panel/Label.text)

func _on_slot_2_pressed():
	colocable_escena = preload("res://scenes/barrera.tscn")
	var item_node = $NinePatchRect/Inventory/slot2/CenterContainer/Panel/item
	if item_node and item_node.texture:
		floating_item.texture = item_node.texture
		floating_item.visible = true
		precio = int($NinePatchRect/Inventory/slot2/CenterContainer/Panel/Label.text)

func _on_slot_3_pressed():
	colocable_escena = preload("res://scenes/trampa.tscn")
	var item_node = $NinePatchRect/Inventory/slot3/CenterContainer/Panel/item
	if item_node and item_node.texture:
		floating_item.texture = item_node.texture
		floating_item.visible = true
		precio = int($NinePatchRect/Inventory/slot3/CenterContainer/Panel/Label.text)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		# Soltar ítem (cancelar arrastre)
		floating_item.visible = false
		floating_item.texture = null
	
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if floating_item.visible and colocable_escena and puntos_jugador >= precio:
			puntos_jugador -= precio
			var mapa = get_tree().get_root().get_node("World").get_child(2).get_child(0) # Ajusta esto según tu nodo raíz
			var objeto = colocable_escena.instantiate()
			objeto.position = get_global_mouse_position()  # Si es Node2D
			mapa.add_child(objeto)
			buy.emit(precio)
			
			# Cancelar arrastre tras colocar
			floating_item.visible = false
			floating_item.texture = null
		else:
			floating_item.visible = false
			floating_item.texture = null



