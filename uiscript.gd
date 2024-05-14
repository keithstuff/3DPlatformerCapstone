extends Control

@onready var ebutton = $OnScreen/EButton
@onready var wispbar1 = $OnScreen/HBoxContainer/Wisp1
@onready var wispbar2 = $OnScreen/HBoxContainer/Wisp2
@onready var wispbar3 = $OnScreen/HBoxContainer/Wisp3
@onready var wispbaroffmaterial = preload('res://Art/materials/darkglow.tres')

@onready var cleartimelabel = $EndScreen/Cleartime/Label
@onready var endscreen = $EndScreen
@onready var onscreen = $OnScreen

var stopwatch := 0.0
var minute = 0
var second = 0
var level_complete = false
# Called when the node enters the scene tree for the first time.
func _ready():
	ebutton.visible = false
	onscreen.visible = false
	endscreen.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	stopwatch += delta
	if level_complete == false:
		cleartimelabel.text = "%02d:%02d" % timer()

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

func timer():
	minute = floor(stopwatch / 60)
	second = int(stopwatch) % 60
	return[minute, second]


func _on_player_character_levelend():
	endscreen.visible = true
	onscreen.visible = false
	level_complete = true


func _on_black_hole_blackholeclose():
	onscreen.visible = true
