extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var piece


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setowner(p):
	piece = p

func update_text():
	if piece != null:
		$ColorRect/VBox/Name.text = piece.type
		$ColorRect/VBox/Grid/ATK2.text = piece.get_attack()
		$ColorRect/VBox/Grid/MAG2.text = piece.get

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
