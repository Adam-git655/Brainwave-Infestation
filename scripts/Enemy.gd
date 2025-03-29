extends CharacterBody2D

var alive = true
var entered
var speed = 170
var direction = Vector2.ZERO
var drop_chance = 0.1
@onready var main = get_node("/root/Main")
@onready var Player = get_node("/root/Main/Player")
@onready var power_up_scene = preload("res://scenes/power_up.tscn")


signal hit_player

func _ready():
	var screen_rect = get_viewport_rect()
	entered = false
	
	var dist = screen_rect.get_center() - position
	
	#check if needs to move horizontally or vertically
	if abs(dist.x) > abs(dist.y):
		direction.x = dist.x
		direction.y = 0
	else:
		direction.y = dist.y
		direction.x = 0
			
func _physics_process(delta):
	if alive:
		if entered == true:
			direction = (Player.position - position)
		direction = direction.normalized()
		velocity = direction * speed
		move_and_slide()
		$AnimatedSprite2D.play("Move")
		if velocity.x != 0:
			if velocity.x > 0:
				$AnimatedSprite2D.flip_h = true
			else:
				$AnimatedSprite2D.flip_h = false
	else:
		pass

func die():
	$Enemy_death.play()
	alive = false
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.animation = "dead"
	$"Parasite-Hitbox/CollisionShape2D".set_deferred('disabled', true)
	if randf() <= drop_chance:
		drop_item()
		queue_free()
	
func drop_item():
	var power_up = power_up_scene.instantiate()
	power_up.position = position
	power_up.power_up_type = randi_range(0,2)
	main.call_deferred('add_child', power_up)
	power_up.add_to_group('powerups')
	
func _on_entrance_timer_timeout():
	entered = true


func _on_parasite_hitbox_body_entered(body):
	if body.is_in_group('Player'):
		hit_player.emit()




