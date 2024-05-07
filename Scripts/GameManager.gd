extends Node

var active_towers = 0
var levelcomplete = false
signal level_completed
signal level_started
@onready var cutcam = $CutsceneCamera
@onready var playercam = $"../PlayerCharacter/TwistPivot/PitchPivot/Camera3D"
@onready var cutscenetimer = $CutsceneTimer
# Called when the node enters the scene tree for the first time.
func _ready():
	active_towers = 0
	cutcam.make_current()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active_towers >= 5:
		level_completed.emit()
	if Input.is_action_just_pressed("endtest"):
		active_towers = 5



func _on_tower_1_tower_activated():
	active_towers += 1
	print(active_towers)


func _on_tower_2_tower_activated():
	active_towers += 1
	print(active_towers)


func _on_tower_3_tower_activated():
	active_towers += 1
	print(active_towers)


func _on_tower_4_tower_activated():
	active_towers += 1
	print(active_towers)


func _on_tower_5_tower_activated():
	active_towers += 1
	print(active_towers)


func _on_level_completed():
	if levelcomplete == false:
		cutcam.make_current()
		cutcam.position = playercam.position
		cutcam.rotation = playercam.rotation
		var tween = get_tree().create_tween()
		tween.tween_property(cutcam, "position", Vector3(0,20,30), 1)
		tween.parallel().tween_property(cutcam, "rotation", Vector3(0,0,0), 1)
		cutscenetimer.start(4)
		levelcomplete = true


func _on_cutscene_timer_timeout():
	cutcam.clear_current()
	
