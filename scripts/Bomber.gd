extends CharacterBody2D

var alive = true
var fake_alive = true
var entered
var speed = 200
var direction = Vector2.ZERO
var exploding = false
var drop_chance = 0.1
@onready var main = get_node("/root/Main")
@onready var Player = get_node("/root/Main/Player")
@onready var power_up_scene = preload("res://scenes/power_up.tscn")

signal explode_player

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
	if fake_alive:
		if entered == true:
			direction = (Player.position - position)
		direction = direction.normalized()
		velocity = direction * speed
		move_and_slide()
		if !exploding:
			$AnimatedSprite2D.play("Move")
	else:
		pass

func die():
	await get_tree().create_timer(0.1).timeout
	$Enemy_death.play()
	fake_alive = false
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.animation = "dead"
	$"Parasite-Hitbox/CollisionShape2D".set_deferred('disabled', true)
	$Death_timer.start()
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
		exploding = true
		$AnimatedSprite2D.play("Explode")
		$Explode_timer.start()
		

func _on_explode_timer_timeout():
	if fake_alive:
		$explosion/CPUParticles2D.emitting = true
		$explosion/Explosion_sound.play()
		await get_tree().create_timer(0.2).timeout
		explode_player.emit()
		die()
		
func _on_death_timer_timeout():
	alive = false
	
