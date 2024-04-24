extends Control

@onready var ebutton = $EButton
@onready var wispbar1 = $HBoxContainer/Wisp1
@onready var wispbar2 = $HBoxContainer/Wisp2
@onready var wispbar3 = $HBoxContainer/Wisp3
@onready var wispbaroffmaterial = preload('res://Art/materials/darkglow.tres')
# Called when the node enters the scene tree for the first time.
func _ready():
	ebutton.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_interact_range_area_entered(area):
	if ebutton.visible == false:
		ebutton.visible = true
	else: ebutton.visible = false


func _on_interact_range_area_exited(area):
	if ebutton.visible == false:
		ebutton.visible = true
	else: ebutton.visible = false


func _on_player_character_assign_wisp_number(num):
	match num:
		1: 
			wispbar1.material = wispbaroffmaterial
		2:
			wispbar2.material = wispbaroffmaterial
		3:
			wispbar3.material = wispbaroffmaterial
		


func _on_player_character_recall_wisp(num):
	match num:
		1: 
			wispbar1.material = null
		2:
			wispbar2.material = null
		3:
			wispbar3.material = null
