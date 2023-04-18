class_name Tile extends Area2D

var damage = 0 #float, 0-1
var chain = 0 #1.1 penalty per chain

signal fully_scorched(coord)
signal healed(coord)

func scorch(amount):
	damage += amount * pow(1.1,chain)
	print("tile scorched: ",amount * pow(1.1,chain), " damage=",damage)
	chain += 1
	$Floor.modulate = global.WHITE*(1-damage) + global.DAMAGE_RED*damage
	if damage >= 1:
		timeout()
		emit_signal("fully_scorched", coord)

func is_scorched()->bool:
	return damage>=1

func heal(amount):
	print("tile healed", amount)
	damage -= amount

func reset_chain():
	chain = 0

func timeout():
	$Scorached.start()
	$Heal.stop()

func endtimeout():
	$Heal.start()
	reset_chain()

func _on_Heal_timeout():
	damage = damage*0.8

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

var coord:Vector2
var cellsize:int
var type:String 

func setup(x=0,y=0,cs=24,t="Wall"):
	coord = Vector2(x,y)
	position = coord*cs
	cellsize = cs
	change_type(t)


func change_type(newtype:String):
	type = newtype
	match type:
		"Wall":
			$Wall.visible = true
			can_travel = false
		"Floor":
			$Floor.visible = true
		"Gold":
			$Gold.visible = true	
			can_travel = false
		"City":
			pass
		"Outpost":
			pass

var can_travel:bool = true



func highlight_off():
	$highlight.visible = false
func highlight_on(color=null):
	if color!=null:
		$highlight.color = color
	$highlight.visible = true

"""
func _unhandled_input(event):
	if event is InputEventMouseButton:
		highlight = true
		get_tree().set_input_as_handled()
"""

signal tile_clicked(coordinate)

func _on_Tile_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed && event.button_index==BUTTON_LEFT):
		emit_signal("tile_clicked", coord)


