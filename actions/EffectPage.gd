extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect.color = global.ACTION_BLUE

func setup(name, text, kws):
	$VBox/Name.text = name
	$VBox/ActionText.action_text = text
	$VBox/ActionText.action_text_keywords = kws
	
	$VBox/ActionText._ready()

func calculate_values() -> Dictionary:
	return $VBox/ActionText.calculate_values()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
