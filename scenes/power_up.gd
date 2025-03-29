extends Area2D

var power_up_type: int
@onready var main = get_node("/root/Main")

@onready var speed_boost_sprite = get_node("/root/Main/Hud/Sprite2D6")
@onready var lives_boost_sprite = get_node("/root/Main/Hud/Sprite2D7")
@onready var shoot_boost_sprite = get_node("/root/Main/Hud/Sprite2D8")

@onready var Bullet_manager = get_node("/root/Main/Bullet_Manager")
@onready var Player = get_node("/root/Main/Player")
@onready var PlayerAnimatedSprite2D = get_node("/root/Main/Player/AnimatedSprite2D")

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play('default')


func _on_body_entered(body):
	if body.is_in_group('Player'):
		Player.is_power_up = true
		PlayerAnimatedSprite2D.play('Powerup')
		if power_up_type == 0:
			body.boost()
			speed_boost_sprite.visible = true
			
		elif power_up_type == 1:
			if main.lives < 5:
				main.lives += 1
				lives_boost_sprite.visible = true
				$AnimatedSprite2D.visible = false
				await get_tree().create_timer(3).timeout
				lives_boost_sprite.visible = false
				
		elif power_up_type == 2:
			Player.shoot_cooldown_boost()
			shoot_boost_sprite.visible = true
			
		speed_boost_sprite.add_to_group('powerup_sprites')
		lives_boost_sprite.add_to_group('powerup_sprites')
		shoot_boost_sprite.add_to_group('powerup_sprites')
		for sprite in get_tree().get_nodes_in_group('powerup_sprites'):
			sprite.modulate.a = 1
		queue_free()



func _on_lives_timeout():
	print('s')
	lives_boost_sprite.visible = false
