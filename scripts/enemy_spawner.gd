extends Node2D

@onready var main = get_node("/root/Main")
var Parasite1_scene = preload("res://scenes/Parasite-1.tscn")
var Parasite2_scene = preload("res://scenes/parasite_2.tscn")
var Parasite3_scene = preload("res://scenes/parasite_3.tscn")
var spawn_points = []

signal hit_p
signal explode_p

func _ready():
	randomize()
	for i in get_children():
		if i is Marker2D:
			spawn_points.append(i)
			

func _on_timer_timeout():
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	if enemies.size() < main.max_enemies:
		var spawn = spawn_points[randi() % spawn_points.size()]
		
		var parasite1 = Parasite1_scene.instantiate()
		parasite1.position = spawn.position
		parasite1.hit_player.connect(hit)
		main.add_child(parasite1)
		parasite1.add_to_group("enemies")
		
func _on_bomber_timer_timeout():
	var bombers = get_tree().get_nodes_in_group("bombers")
	
	if bombers.size() < main.max_bombers:
		var spawn = spawn_points[randi() % spawn_points.size()]
		
		var parasite2 = Parasite2_scene.instantiate()
		parasite2.position = spawn.position
		parasite2.explode_player.connect(explode)
		main.add_child(parasite2)
		parasite2.add_to_group("bombers")


func _on_speeder_timer_timeout():
	var speeders = get_tree().get_nodes_in_group("speeders")
	
	if speeders.size() < main.max_speeders:
		var spawn = spawn_points[randi() % spawn_points.size()]	
		var parasite3 = Parasite3_scene.instantiate()
		parasite3.position = spawn.position
		parasite3.hit_player.connect(hit)
		main.add_child(parasite3)
		parasite3.add_to_group("speeders")
	
func hit():
	hit_p.emit()
	
func explode():
	explode_p.emit()
	





