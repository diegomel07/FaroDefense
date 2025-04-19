extends Control

signal opened
signal closed

var is_open: bool = false

@onready var inventory: Inventory = preload("res://inventory/items/player_inventory.tres")
@onready var slots = $NinePatchRect/Inventory.get_children()
@onready var craft_slots = $NinePatchRect/Craft.get_children()
@onready var craftin_slot = $NinePatchRect/craftinSlot
@onready var materials_slots = $NinePatchRect/Materials.get_children()


@onready var fence_slot:InventorySlot = InventorySlot.new()
@onready var hamster_slot:InventorySlot = InventorySlot.new()


@onready var fence_item:InventoryItem = preload("res://inventory/items/fence.tres")
@onready var hamster_item:InventoryItem = preload("res://inventory/items/hamster.tres")

func _ready():
	
	$NinePatchRect/Craft/fence/CenterContainer/Panel/Label.visible = false
	$NinePatchRect/Craft/hamster/CenterContainer/Panel/Label.visible = false
	
	fence_slot.item = fence_item
	fence_slot.amount = 0
	hamster_slot.item = hamster_item
	hamster_slot.amount = 0
	
	# añadiendo las imagenes a los slots de crafteo
	craft_slots[0].update(fence_slot)
	craft_slots[1].update(hamster_slot)
	
	connect_slots()
	inventory.updated.connect(update)
	update()
	

func update():
	$NinePatchRect/Craft/fence/CenterContainer/Panel/Label.visible = false
	$NinePatchRect/Craft/hamster/CenterContainer/Panel/Label.visible = false
	for i in range(min(inventory.slots.size(), slots.size())):
		slots[i].update(inventory.slots[i])

func connect_slots():
	for slot in craft_slots:
		var callable = Callable(on_slot_clicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)

func open():
	update()
	visible = true
	is_open = true
	opened.emit()

func close():
	visible = false
	is_open = false
	closed.emit()
	
func on_slot_clicked(slot):
	$NinePatchRect/craftinSlot/CenterContainer/Panel/Label.visible = false
	craftin_slot.set_texture(slot.get_texture())
	craftin_slot.item_name = slot.item_name
	
	if slot.item_name == 'fence':
		put_material()
		put_material(['wood'], 4)
	elif slot.item_name == 'hamster':
		put_material()
		put_material(['rock', 'wood'], 8)

	
	update()

func put_material(materials: Array[String] = [], amount = 0):
	
	if amount == 0:
		for slot in materials_slots:
			slot.update(InventorySlot.new())
	
	for i in range(materials.size()):
		var new_slot:InventorySlot = InventorySlot.new()
		if materials[i] == 'wood':	
			new_slot.item = preload("res://inventory/items/wood.tres")
		elif materials[i] == 'rock':	
			new_slot.item = preload("res://inventory/items/rock.tres")
		new_slot.amount = amount
		materials_slots[i].update(new_slot)


func _on_crafting_button_pressed():
	var crafteable: bool
	var my_materials = {'wood': 0, 'rock': 0}
	
	for slot in inventory.slots:
		if slot.item:
			if slot.item.name in my_materials:
				my_materials[slot.item.name] = slot.amount
	
	if craftin_slot.item_name in ['hamster', 'fence']:
		print('Vamos a craftear una ', craftin_slot.item_name)
		# revisar si tenemos los materiales
		for slot in materials_slots:
			if slot.item_name:
				if my_materials[slot.item_name] >= slot.amount:
					my_materials[slot.item_name] -= slot.amount
					if my_materials[slot.item_name] < 0:
						my_materials[slot.item_name] = 0
					crafteable = true
				else:
					crafteable = false
	if crafteable:
		if craftin_slot.item_name == 'fence':
			print('nueva fence')
			inventory.insert(preload("res://inventory/items/fence.tres"))
			# borrar los recursos gastados
		if craftin_slot.item_name == 'hamster':
			print('nueva hamster')
			inventory.insert(preload("res://inventory/items/hamster.tres"))
			# borrar los recursos gastados
		for slot in inventory.slots:
			if slot.item:
				if slot.item.name in my_materials:
					slot.amount = my_materials[slot.item.name]
	update()
