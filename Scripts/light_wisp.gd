extends Node3D

@onready var tween = get_tree().create_tween()
@onready var player = $"../PlayerCharacter"
var number = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	tween.tween_property(self, "position", Vector3(position.x, position.y+1, position.z), 1)
	player.assign_wisp_number.connect(_assign_number)
	player.recall_wisp.connect(_recall_recieved)
	
func _assign_number(num):
	if number == 0:
		number = num

func _recall_recieved(num):
	if number == num:
		queue_free()
