extends Node2D
class_name Equipment

func _ready():
	$HUD.type = "equip"
	$HUD._ready()

var atk:= 30
var mag:= 30
var spd:= 30

func sum(arr):
	var s := 0; for x in arr: s += x; return s

func randomize_stats():
	var sum = atk+mag+spd
	var delta:int = round(global.random.randfn(0, 3))

	#equally distribute
	var deltas = [delta/3,delta/3,delta/3]
	var remaining = delta-sum(deltas)
	for i in range(abs(remaining)):
		deltas[i] += remaining/int(sign(remaining))
	
	deltas.shuffle()
	
	#more rand steps the lower the delta is
	var steps = floor((4-delta)/2.0)
	if delta<0: steps += 1 
	
	for n in range(steps):
		deltas.shuffle()
		
		var s:int = sign(deltas[0])
		
		if s==0: s = (randi()%2)*2-1
		
		deltas[0] += s
		deltas[1] -= s
	
	deltas.shuffle()
	#print(delta, deltas)
	atk+=deltas[0]; mag+=deltas[1]; spd+=deltas[2]


func setstats(a,m,s):
	atk = a
	mag = m
	spd = s
	randomize_stats()
	$HUD.setstats(atk,mag,spd)

var oneshot:=true

var cost := 100

remotesync func buy(coord:Vector2):
	var p = global.get_map().get_piece(coord)
	p.add_equip(self)
	queue_free()
