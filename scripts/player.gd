extends CharacterBody2D

const START_SPEED = 320
const BOOST_SPEED = 500
const START_SHOOT_COOLDOWN = 0.25
const BOOST_SHOOT_COOLDOWN = 0.15
var speed = START_SPEED
var is_boosting = false
signal shoot
var can_shoot = true
var damage = false
var spawn_pos = Vector2(570, 302)
var can_explode = false
var is_power_up = false
@onready var screen_size = get_viewport_rect().size
@onready var gunshot = $Gunshot_sound
@onready var player_hitbox = $PlayerHitbox/CollisionShape2D

@onready var speed_boost_sprite = get_node("/root/Main/Hud/Sprite2D6")
@onready var lives_boost_sprite = get_node("/root/Main/Hud/Sprite2D7")
@onready var shoot_boost_sprite = get_node("/root/Main/Hud/Sprite2D8")
@onready var boost_anim_player = get_node("/root/Main/Hud/Boost_blink")
var is_melee = false

func _ready():
	$shoot_cooldown.wait_time = START_SHOOT_COOLDOWN
	$Speed_particle.emitting = false
	player_hitbox.disabled = true
	$AnimatedSprite2D.play("idle")
	speed_boost_sprite.visible = false
	lives_boost_sprite.visible = false
	shoot_boost_sprite.visible = false
	

func get_input():
	var input_dir = Input.get_vector("left", "right", "up", "down")
	velocity = input_dir * speed
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_shoot:
		var dir = get_global_mouse_position() - position
		shoot.emit(position, dir)
		gunshot.play()
		can_shoot = false
		$shoot_cooldown.start()
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		player_hitbox.disabled = false
		is_melee = true
		$AnimatedSprite2D.play("Melee")
		
		
func _physics_process(delta):
	get_input()
	move_and_slide()
	
	position = position.clamp(Vector2.ZERO, screen_size)
	
	
	if damage == false and is_melee == false and is_power_up == false:
		if velocity.length() != 0:
			$AnimatedSprite2D.play("move")
		else:
			$AnimatedSprite2D.play("idle")
	
	if get_global_mouse_position().x > position.x:
		$AnimatedSprite2D.flip_h = false
	elif get_global_mouse_position().x < position.x:
		$AnimatedSprite2D.flip_h = true
	if !is_boosting:	
		if get_parent().lives == 3:
			speed = 320
		elif get_parent().lives == 2:
			speed = 270
		elif get_parent().lives == 1:
			speed = 220


func boost():
	$Boost_timer.start()
	$Boost_blink_timer.start()
	is_boosting = true
	speed = BOOST_SPEED
	$Speed_particle.emitting = true
	
func shoot_cooldown_boost():
	$shoot_cooldown.wait_time = BOOST_SHOOT_COOLDOWN
	$Shoot_cooldown_boost_timer.start()
	$shoot_cooldown_blink_timer.start()

func _on_shoot_cooldown_boost_timer_timeout():
	$shoot_cooldown.wait_time = START_SHOOT_COOLDOWN
	shoot_boost_sprite.visible = false
func _on_shoot_cooldown_blink_timer_timeout():
	boost_anim_player.play('shoot_boost_blink')
	
func _on_shoot_cooldown_timeout():
	can_shoot = true


func _on_enemy_spawner_hit_p():
	damage = true
	$AnimatedSprite2D.play("damage")
	get_parent().lives -= 1
	
func _on_enemy_spawner_explode_p():
	if can_explode:
		damage = true
		$AnimatedSprite2D.play("damage")
		get_parent().lives -= 3
	
func _on_animated_sprite_2d_animation_finished():
	damage = false
	player_hitbox.disabled = true
	is_melee = false
	is_power_up = false

	
func reset():
	position = spawn_pos
	speed = START_SPEED
	$shoot_cooldown.wait_time = START_SHOOT_COOLDOWN
	$Speed_particle.emitting = false
	$AnimatedSprite2D.stop()
	damage = false
	is_melee = false
	is_power_up = false
	

func _on_player_hurtbox_body_entered(body):
	if body.is_in_group("bombers"):
		can_explode = true
		
func _on_player_hurtbox_body_exited(body):
	if body.is_in_group("bombers"):
		can_explode = false

func _on_player_hitbox_body_entered(body):
	if body.is_in_group("bombers"):
		body.die()
		

func _on_boost_timer_timeout():
	speed = START_SPEED
	$Speed_particle.emitting = false
	is_boosting = false
	speed_boost_sprite.visible = false
func _on_boost_blink_timer_timeout():
	boost_anim_player.play('speed_boost_blink')


