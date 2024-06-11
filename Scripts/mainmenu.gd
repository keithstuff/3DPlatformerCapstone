extends Control

signal begin
var has_begun = false
# Called when the node enters the scene tree for the first time.
func _ready():
	ResourceLoader.load_threaded_request('res://Scenes/test_level.tscn')




func _on_button_pressed():
	if has_begun == false:
		begin.emit()
		has_begun = true
		get_tree().change_scene_to_file('res://Scenes/test_level.tscn')
