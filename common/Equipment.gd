extends Node2D
class_name Equipment

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

var oneshot:=true

remotesync func buy(coord:Vector2):
	var p = global.get_map().get_piece(coord)
	p.add_equip(self)
	queue_free()
