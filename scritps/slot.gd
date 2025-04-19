extends Button


@onready var background = $background
@onready var item_sprite = $CenterContainer/Panel/item
@onready var amount_label = $CenterContainer/Panel/Label

var item_name
var amount: int
var item

func update(slot: InventorySlot):
	if !slot.item:
		item = slot.item
		background.frame = 0
		item_sprite.visible = false
		amount_label.visible = false
	else:
		background.frame = 0
		item_sprite.visible = true
		item_sprite.texture = slot.item.texture
		item_name = slot.item.name

func set_texture(texture: Texture2D):
	item_sprite.texture = texture

func get_texture():
	return item_sprite.texture

func takeItem():
	pass
