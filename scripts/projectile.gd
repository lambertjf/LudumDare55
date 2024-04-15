extends RigidBody3D

func _ready():
	var timer = Timer.new()
	timer.wait_time = 5.0
	timer.one_shot = true
	timer.connect('timeout', _on_timeout)
	add_child(timer)
	timer.start()

func _on_timeout():
	queue_free()
	
func _on_body_entered(body):
	queue_free()
