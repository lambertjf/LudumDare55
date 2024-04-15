extends Control

var summoning = false
@onready var summon_hand = $SummonHand
@onready var anim = $SummonHand/AnimationPlayer

@onready var ray_cast = get_node('../Camera3D/RayCast3D')
@onready var summon_area = get_node('../SummonArea')
@onready var cursor = get_node('../../FX/SummonCursor')
@onready var plat_container = get_node('../../PlayerPlatforms')

@onready var base_position = summon_hand.position
var shake = 10

var platform_scene = preload('res://scenes/platform.tscn')
var platforms = []
@export var num_platforms = 5
var plat_cursor = 0

var cooldown = false
@onready var cooldown_timer = $CooldownTimer
var cooldown_time = 1

@onready var progress_bar = $ProgressBar

func _ready():
	for i in range(num_platforms):
		var new_plat = platform_scene.instantiate()
		plat_container.add_child(new_plat)
		platforms.append(new_plat)
		new_plat.global_position = Vector3(0, -1000, 0)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed('summon'):
		start_summon()
	if Input.is_action_just_released('summon'):
		finish_summon()

func _animation_finished(anim_name):
	anim.stop()

func start_summon():
	summoning = true

func raise_platform(c_point):
	platforms[plat_cursor].global_position = c_point
	platforms[plat_cursor].get_node('AnimationPlayer').play('raise')
	platforms[plat_cursor].get_node('AudioStreamPlayer3D').play()
	plat_cursor = (plat_cursor + 1) % num_platforms
	
func reset_platforms():
	for p in platforms:
		p.global_position = Vector3(0, -500, 0)

func _on_cooldown_timer_timeout():
	cooldown = false

func finish_summon():
	summoning = false
	if ray_cast.is_colliding() and not cooldown:
		var collision_point = ray_cast.get_collision_point()
		anim.play('raise')
		raise_platform(collision_point)
		cooldown_timer.start(cooldown_time)
		cooldown = true
		
func shake_pos():
	summon_hand.position.x = base_position.x + randf_range(-shake, shake)
	summon_hand.position.y = base_position.y + randf_range(-shake, shake)

func reset_pos():
	summon_hand.position = base_position

func cursor_on():
	if not cursor.emitting:
		cursor.emitting = true
		
func cursor_off():
	if cursor.emitting:
		cursor.emitting = false

func _process(delta):
	progress_bar.value = progress_bar.max_value - (cooldown_timer.time_left / cooldown_time)
	if summoning:
		shake_pos()
		if ray_cast.is_colliding() and not cooldown:
			var collision_point = ray_cast.get_collision_point()
			cursor.global_position = collision_point
			cursor_on()
		else:
			cursor_off()
	else:
		reset_pos()
		cursor_off()

