extends Node2D

@export var RANDOM_SHAKE_STRENGTH: float = 1.5
# Multiplier for lerping the shake strength to zero
@export var SHAKE_DECAY_RATE: float = 0.0
@onready var camera = $Camera2D
@onready var rand = RandomNumberGenerator.new()

var shake_strength: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play('Cutscene')

func play_anim(animation_name):
	$AnimatedSprite2D.play(animation_name)
	$AnimatedSprite2D2.play(animation_name)

func play_anim_bomber(animation_name):
	$AnimatedSprite2D3.play(animation_name)
	
func play_player_anim(animation_name):
	$PlayerAnimatedSprite2d.play(animation_name)
	if animation_name == 'damage':
		$PlayerAnimatedSprite2d/PointLight2D.texture_scale = 0.009
		
func _process(delta):
	if $PlayerAnimatedSprite2d.animation == 'damage':
		shake_strength = RANDOM_SHAKE_STRENGTH
		shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
		camera.offset = get_random_offset()

func get_random_offset():
	return Vector2(
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)

func stop_anim():
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D2.stop()
	$AnimatedSprite2D3.stop()
	
func stop_player_anim():
	$PlayerAnimatedSprite2d.stop()
	
func _on_next_pressed():
	if $Next.text == 'Next':
		$AnimationPlayer.play("Cutscene2")
		$PlayerAnimatedSprite2d/PointLight2D.texture_scale = 0.02
	else:
		get_tree().change_scene_to_file('res://scenes/main.tscn')
