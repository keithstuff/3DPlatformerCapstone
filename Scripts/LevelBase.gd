extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	ResourceLoader.load_threaded_request('res://Scenes/test_level.tscn')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_main_menu_begin():
	pass
