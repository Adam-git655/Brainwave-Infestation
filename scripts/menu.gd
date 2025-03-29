extends Control



func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/cutscene.tscn")

func _on_controls_pressed():
	get_tree().change_scene_to_file("res://scenes/Controls.tscn")

	
func _on_wild_cards_pressed():
	get_tree().change_scene_to_file("res://scenes/Wild_cards.tscn")


func _on_quit_pressed():
	get_tree().quit()









