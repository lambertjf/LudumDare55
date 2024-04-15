extends Area3D

var speed = 0
@onready var player = get_node('/root/World/Player/Camera3D')
@onready var effect = $DeathEffect
@onready var model = $Model
@onready var wait_timer = $WaitTimer
@onready var sound_timer = $SoundTimer
@onready var audio = $AudioStreamPlayer3D
var death_sound = preload("res://assets/enemy_death.ogg")

var can_push = true
var health = 1
var waiting = false
var wait_time = 3.0

func _on_wait_timer_timeout():
	waiting = false

func _ready():
	speed = get_node('/root/World').cur_level.enemy_speed
	
func _process(_delta):
	if not waiting:
		look_at(player.global_position)
		global_position = global_position.move_toward(player.global_position, speed * .1)
	
func _on_body_entered(body):
	if body.name == 'Player':
		if can_push and not waiting:
			body.hit_by_enemy(self)
			wait_timer.start(wait_time)
			waiting = true
	if body.get_meta('is_projectile', false):
		health -= 1
		print('Hit')
	if health < 1 and can_push:
		can_push = false
		model.visible = false
		effect.emitting = true
		audio.stream = death_sound
		audio.play()
		sound_timer.stop()
		await get_tree().create_timer(1.0).timeout
		queue_free()
		
func _on_sound_timer_timeout():
	audio.play()
