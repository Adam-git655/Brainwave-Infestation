extends Node2D
var lives = 3
var max_enemies = 7
var max_bombers = 1
var max_speeders = 2
var wave = 1
var doing_next_wave = false


@export var RANDOM_SHAKE_STRENGTH: float = 1.0
# Multiplier for lerping the shake strength to zero
@export var SHAKE_DECAY_RATE: float = 0.0
@onready var camera = $Camera2D
@onready var rand = RandomNumberGenerator.new()

var shake_strength: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()
	show_wave_number()

func show_wave_number():
	$Hud/WavesLabel.visible = true
	$Hud/WavesLabel.text = "WAVE " + str(wave)
	if wave == 5:
		$Hud/BigHeadMode.visible = true
		$Player/shoot_cooldown.wait_time = $Player.BOOST_SHOOT_COOLDOWN
		$Player.scale = Vector2(3, 3)
	elif wave >= 10:
		$Hud/BigHeadMode.visible = false
	else:
		$Hud/BigHeadMode.visible = false
		$Player/shoot_cooldown.wait_time = $Player.START_SHOOT_COOLDOWN
		$Player.scale = Vector2(1,1)
		
	get_tree().paused = true
	$Wave_Timer.start()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Player/PointLight2D.texture_scale = lives
	if lives == 5:
		$Hud/Sprite2D.visible = true
		$Hud/Sprite2D2.visible = true
		$Hud/Sprite2D3.visible = true
		$Hud/Sprite2D4.visible = true
		$Hud/Sprite2D5.visible = true
	elif lives == 4:
		$Hud/Sprite2D.visible = true
		$Hud/Sprite2D2.visible = true
		$Hud/Sprite2D3.visible = true
		$Hud/Sprite2D4.visible = true
		$Hud/Sprite2D5.visible = false
	elif lives == 3:
		$Hud/Sprite2D.visible = true
		$Hud/Sprite2D2.visible = true
		$Hud/Sprite2D3.visible = true
		$Hud/Sprite2D4.visible = false
		$Hud/Sprite2D5.visible = false
	elif lives == 2:
		$Hud/Sprite2D.visible = true
		$Hud/Sprite2D2.visible = true
		$Hud/Sprite2D3.visible = false
		$Hud/Sprite2D4.visible = false
		$Hud/Sprite2D5.visible = false
		shake_strength = RANDOM_SHAKE_STRENGTH
		shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
		camera.offset = get_random_offset()
	elif lives == 1:
		$Hud/Sprite2D.visible = true
		$Hud/Sprite2D2.visible = false
		$Hud/Sprite2D3.visible = false
		$Hud/Sprite2D4.visible = false
		$Hud/Sprite2D5.visible = false
		shake_strength = RANDOM_SHAKE_STRENGTH + 1.0
		shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
		camera.offset = get_random_offset()
	elif lives <= 0 or lives < 1:
		$Hud/Sprite2D.visible = false
		$Hud/Sprite2D2.visible = false
		$Hud/Sprite2D3.visible = false
		$Hud/Sprite2D4.visible = false
		$Hud/Sprite2D5.visible = false
		await get_tree().create_timer(0.3).timeout
		get_tree().paused = true
		$GameOver/WavesSurvivedLabel.text = 'Waves Survived: ' + str(wave - 1)
		BgMusic.stop()
		$GameOver.show()
		
	if next_wave():
		wave += 1
		print("new wave")
		show_wave_number()
		reset()

		

func get_random_offset():
	return Vector2(
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)
	
func new_game():
	lives = 3
	max_enemies = 7
	max_bombers = 1
	max_speeders = 2
	wave = 1
	rand.randomize()
	$Enemy_Spawner/Timer.wait_time = 1.0
	$Enemy_Spawner/Bomber_Timer.wait_time = 5.0
	$Enemy_Spawner/speeder_Timer.wait_time = 3.0
	$Hud/BigHeadMode.visible = false
	$Player.reset()
	$Player.scale = Vector2(1,1)
	get_tree().call_group('enemies', 'queue_free')	
	get_tree().call_group('bullets', 'queue_free')	
	get_tree().call_group('bombers', 'queue_free')
	get_tree().call_group('speeders', 'queue_free')
	get_tree().call_group('powerups', 'queue_free')
	for sprite in get_tree().get_nodes_in_group('powerup_sprites'):
		sprite.visible = false
	get_tree().paused = false
	$GameOver.hide()
	
func reset():
	lives = 3
	max_enemies += 1
	max_bombers += 1
	max_speeders += 1
	if $Enemy_Spawner/Timer.wait_time > 0.25:
		$Enemy_Spawner/Timer.wait_time -= 0.05
	if $Enemy_Spawner/Bomber_Timer.wait_time > 0.25:
		$Enemy_Spawner/Bomber_Timer.wait_time -= 0.25
	if $Enemy_Spawner/speeder_Timer.wait_time > 0.25:
		$Enemy_Spawner/speeder_Timer.wait_time -= 0.15
		
	$Player.reset()
	get_tree().call_group('enemies', 'queue_free')	
	get_tree().call_group('bullets', 'queue_free')	
	get_tree().call_group('bombers', 'queue_free')
	get_tree().call_group('speeders', 'queue_free')
	get_tree().call_group('powerups', 'queue_free')
	for sprite in get_tree().get_nodes_in_group('powerup_sprites'):
		sprite.visible = false
	$Player/PlayerHitbox/CollisionShape2D.disabled = true
	


func next_wave():
	var all_dead = true
	var enemies = get_tree().get_nodes_in_group("enemies")
	var bombers = get_tree().get_nodes_in_group("bombers")
	var speeders = get_tree().get_nodes_in_group("speeders")
	
	if enemies.size() == max_enemies and bombers.size() == max_bombers and speeders.size() == max_speeders:
		for e in enemies:
			if e.alive:
				all_dead = false
		for b in bombers:
			if b.alive:
				all_dead = false
		for s in speeders:
			if s.alive:
				all_dead = false	
		return all_dead
	else:
		return false
		
func _on_wave_timer_timeout():
	get_tree().paused = false
	$Hud/WavesLabel.visible = false
	$Hud/BigHeadMode.visible = false


func _on_play_again_pressed():
	print("pressed")
	BgMusic.play()
	new_game()
	show_wave_number()




	
	
