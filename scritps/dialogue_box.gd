extends Control

var texts : Array = []
var current_text_index : int = 0
var current_text : String = ""
var displayed_text : String = ""
var char_index : int = 0
var is_animating : bool = false

@onready var visual_text : RichTextLabel = $PanelContainer/RichTextLabel
@onready var animation_mark : AnimationPlayer = $PanelContainer/AnimationPlayer
@onready var mark : Control = $PanelContainer/Control
@onready var timer : Timer = $Timer
@onready var talk_sound : AudioStreamPlayer2D = $AudioStreamPlayer2D

signal dialogue_finished  # <- Señal para avisar al mundo si se necesita

func _ready():
	visible = false
	visual_text.visible_ratio = 1
	mark.visible = false
	set_process(false)

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		if is_animating:
			skip_text()
		else:
			next_text()

func show_text():
	if texts.is_empty():
		push_warning("No hay textos asignados al DialogueBox.")
		return

	visible = true
	set_process(true)
	get_tree().paused = true  
	is_animating = true
	char_index = 0
	displayed_text = ""
	current_text = texts[current_text_index]
	timer.start()
	mark.visible = false

func _on_Timer_timeout():
	if char_index < current_text.length():
		var char = current_text[char_index]
		displayed_text += char
		visual_text.bbcode_text = displayed_text
		char_index += 1

		if char != " " and char != "\n":
			if !talk_sound.playing:
				talk_sound.play()
	else:
		timer.stop()
		finish_show_text()

func skip_text():
	timer.stop()
	displayed_text = current_text
	visual_text.bbcode_text = displayed_text
	finish_show_text()

func next_text():
	if current_text_index < texts.size() - 1:
		current_text_index += 1
		show_text()
	else:
		set_process(false)
		visible = false
		current_text_index = 0
		get_tree().paused = false 
		dialogue_finished.emit()  

func finish_show_text():
	is_animating = false
	mark.visible = true
	animation_mark.play("continue")
