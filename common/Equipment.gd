extends Node2D


func _ready():
	$HUD.type = "equip"
	$HUD._ready()

var atk:= 30
var mag:= 30
var spd:= 30

func setstats(a,m,s):
	atk = a
	mag = m
	spd = s
	$HUD.setstats(a,m,s)
