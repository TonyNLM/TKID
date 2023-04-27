extends Node2D



var belongs_to = null
func setowner(city):
	belongs_to = city
	$Red/HBoxContainer/ProgressBar.max_value = belongs_to.win_threshold
	$Blue/HBoxContainer/ProgressBar.max_value = belongs_to.win_threshold

func _process(delta):
	var win = belongs_to.win_threshold
	var vals = belongs_to.control
	$Red/HBoxContainer/Label.text = str(vals["red"])+"/"+str(win)
	$Blue/HBoxContainer/Label.text = str(vals["blue"])+"/"+str(win)

	$Red/HBoxContainer/ProgressBar.value = vals["red"]
	$Blue/HBoxContainer/ProgressBar.value = vals["blue"]
	
