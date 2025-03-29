extends Node2D

@export var Bullet_scene : PackedScene
@onready var Player = get_node('/root/Main/Player')
		

func _on_player_shoot(pos, dir):
	var bullet = Bullet_scene.instantiate()
	add_child(bullet)		
	bullet.position = pos
	bullet.direction = dir.normalized()
	bullet.add_to_group('bullets')
			
