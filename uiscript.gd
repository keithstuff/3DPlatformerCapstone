extends Control

@onready var ebutton = $EButton


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
