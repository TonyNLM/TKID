extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var type := "action"

var active = null

# Called when the node enters the scene tree for the first time.
func _ready():
	match type:
		"action":
			$ColorRect.color = global.ACTION_BLUE
			active = $EffectPage
		"equip":
			$ColorRect.color = global.EQUIP_BROWN
			active = $StatPage


func _on_Button_mouse_entered():
	active.show()
	$Line2D.show()
func _on_Button_mouse_exited():
	active.hide()
	$Line2D.hide()

func disable():
	$Button.disabled = true
	$Button.modulate = Color(0.5,0.5,0.5,1)
func enable():
	$Button.disabled = false
	$Button.modulate = Color(1,1,1,1)
