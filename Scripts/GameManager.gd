extends Node

var active_towers = 0
var levelcomplete = false
signal level_completed
signal level_started
@onready var cutcam = $CutsceneCamera
@onready var playercam = $"../PlayerCharacter/TwistPivot/PitchPivot/Camera3D"
@onready var blackhole = $"../BlackHole"
@onready var player = $"../PlayerCharacter"
@onready var cutscenetimer = $CutsceneTimer

@onready var spawnpoint = blackhole.position

signal respawn

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
	spawnpoint = player.position


func _on_tower_2_tower_activated():
	active_towers += 1
	print(active_towers)
	spawnpoint = player.position


func _on_tower_3_tower_activated():
	active_towers += 1
	print(active_towers)
	spawnpoint = player.position


func _on_tower_4_tower_activated():
	active_towers += 1
	print(active_towers)


func _on_tower_5_tower_activated():
	active_towers += 1
	print(active_towers)
	spawnpoint = player.position


func _on_level_completed():
	if levelcomplete == false:
		cutcam.make_current()
		var tween = get_tree().create_tween()
		cutscenetimer.start(4)
		levelcomplete = true


func _on_cutscene_timer_timeout():
	cutcam.clear_current()
	


func _on_player_character_fizzled():
	$FizzleTimer.start(3)


func _on_fizzle_timer_timeout():
	player.position = spawnpoint
	respawn.emit()
