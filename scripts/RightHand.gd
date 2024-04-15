extends Control

@onready var shoot_hand = $ShootHand
@onready var idle_hand = $IdleHand
@onready var shoot_timer = $ShootTimer
@onready var audio = $AudioStreamPlayer

@onready var emit_point = get_node('../Camera3D/EmitPoint')
@onready var effect = get_node('../Camera3D/EmitPoint/ShootEffect')
@onready var camera = get_node('../Camera3D')

var projectile = preload("res://scenes/projectile.tscn")
var projectile_speed = 20

var base_position = position
var shake = 10

func shoot_timer_done():
	hand_frame('idle')
	reset_pos()

func hand_frame(hand):
	if hand == 'shoot':
		shoot_hand.visible = true
		idle_hand.visible = false
	if hand == 'idle':
		shoot_hand.visible = false
		idle_hand.visible = true

func shake_pos():
	position.x = base_position.x + randf_range(-shake, shake)
	position.y = base_position.y + randf_range(-shake, shake)

func reset_pos():
	position = base_position

func shoot():
	hand_frame('shoot')
	shake_pos()
	audio.play()
	effect.restart()
	effect.emitting = true
	shoot_timer.start(0.5)
	
	var new_proj = projectile.instantiate()
	get_node('/root/World').add_child(new_proj)
	new_proj.global_transform = emit_point.global_transform
	new_proj.linear_velocity = -1 * camera.get_global_transform().basis.z * projectile_speed
	
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("shoot"): shoot()
	
func _ready():
	pass # Replace with function body.

func _process(delta):
	pass
