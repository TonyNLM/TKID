class_name Player extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var health:int = 2000
var max_health:int = 2000
var gold: int = 250

var color:="red"
var player_name:= "red"

# Called when the node enters the scene tree for the first time.
func _ready():
	$PlayerHUD.setup(self)



func damage(amount):
	health -= amount
	if health<=0:
		global.win_game(global.flip_player(color))

func heal(amount):
	health+=amount
	if health>max_health:
		health = max_health
	
func gain_gold(amount:int):
	gold += amount
func lose_gold(amount:int):
	gold -= amount
	if gold<0: gold=0
