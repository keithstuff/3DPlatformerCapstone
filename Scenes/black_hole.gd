extends Node3D
@onready var mesh = $MeshInstance3D
@onready var particles1 = $GPUParticles3D2
@onready var particles2 = $GPUParticles3D3
@onready var anim = $AnimationPlayer
@onready var animtree = $AnimationTree
var animationfired = false


# Called when the node enters the scene tree for the first time.
func _ready():
	particles1.visible = false
	particles2.visible = false
	$BlackHoleGravity.visible = false
	animtree["parameters/Blend2/blend_amount"] = 1


func _on_cutscene_timer_timeout():
	$BlackHoleGravity.visible = true
	


func _on_game_manager_level_completed():
	particles1.visible = true
	particles2.visible = true
	if animationfired == false:
		animtree["parameters/OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		animtree["parameters/Blend2/blend_amount"] = 1
		animationfired = true

func _black_hole_open():
	animtree["parameters/OneShot2/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	animtree["parameters/Blend2/blend_amount"] = 0
	
