extends Node2D


func _ready():
	pass

func set_value(value):
	$HBoxContainer/ProgressBar.value = value*100
	$HBoxContainer/Label.text = "%.2f"%(value*100)
