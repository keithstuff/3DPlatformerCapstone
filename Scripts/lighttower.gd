extends StaticBody3D

@onready var player = $"../PlayerCharacter"
signal tower_activated()

var on_material = preload("res://Art/materials/tower1.tres")
var off_material = preload("res://Art/materials/tower2.tres")
@onready var body = $CollisionShape3D
@onready var self_area = $Area3D
@onready var light = $OmniLight3D
var player_area = Area3D

var interactable = false

# Called when the node enters the scene tree for the first time.
func _ready():
	light.light_energy = 0
	light.light_indirect_energy = 0
	$LightObject1.mesh.material = off_material
	$LightObject2.mesh.material = off_material


func _on_area_3d_area_entered(area):
	if area.is_in_group("player"):
		interactable = true

func _on_area_3d_area_exited(area):
	if area.is_in_group("player"):
		interactable = false
	
func _process(delta):
		if Input.is_action_just_pressed("interact") and interactable == true:
			light.light_energy = 1
			light.light_indirect_energy = 1
			$LightObject1.mesh.material = on_material
			$LightObject2.mesh.material = on_material
			self_area.queue_free()
			tower_activated.emit()
			
		



