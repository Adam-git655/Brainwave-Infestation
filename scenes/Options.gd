extends Control


# Called when the node enters the scene tree for the first time.


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
