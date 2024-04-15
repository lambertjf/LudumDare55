extends Node3D

func _ready():
	$Control/Label2.text = Global.completion_time.pad_decimals(0)
