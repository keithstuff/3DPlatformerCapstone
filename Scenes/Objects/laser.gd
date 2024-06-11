extends StaticBody3D


signal touching_player(num)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		print("PLAYER DETECTED HOLY MOLY")
		touching_player.emit(0)



func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		touching_player.emit(1)


