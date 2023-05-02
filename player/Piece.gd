class_name Piece extends Node2D

var player:Player

var health: int
var attack: int
var speed:int
var magic:int 

#bookkeeping vars
var added_attack:int
var added_speed:int
var added_magic:int

func get_attack() -> int:
	var mult = attack_mult[type]
	return int((attack+added_attack)*mult)
func get_magic()->int:
	var mult = magic_mult[type]
	return int((magic+added_magic)*mult)
func get_speed()->int:
	var mult = speed_mult[type]
	return int((speed+added_speed)*mult)
func get_max_health()->int:
	return int(health_mult[type] * get_magic())

var type := "Pawn"
var health_mult = {"Pawn":10, "Knight":15, "Rook":20, "Bishop":5, "Queen":25}
var attack_mult = {"Pawn":1, "Knight":0.85, "Rook":1.15, "Bishop":0.85, "Queen":1.25}
var speed_mult = {"Pawn":1, "Knight":1.15, "Rook":0.85, "Bishop":0.85, "Queen":1.25}
var magic_mult = {"Pawn":1, "Knight":0.85, "Rook":0.85, "Bishop":1.15, "Queen":1.25}

var coordinate:Vector2

var base_move: Action
var base_attack: Action

var class_skill: Action = null
var extra_move: Action = null
var extra_skill: Action = null

var all_skills:Array = []

const higher := 125
const lower := 75

var color:String

func check_evolve():
	if type=="Pawn":
		var atk = get_attack(); var mag = get_magic(); var spd = get_speed(); var old_health = get_max_health()
		if atk>=higher and mag<=lower and spd<=lower:
			type = "Rook"
			$Area2D/Sprite.texture = global.black_rook if player.color == "red" else global.white_rook
			$BaseMove.get_possible_targets = global.get_map().rook_move
			$BaseMove.settext("Move (rook)")
			class_skill = global.new_rook_skill()
		elif mag>=higher and atk<=lower and spd<=lower:
			type = "Bishop"
			$Area2D/Sprite.texture = global.black_bishop if player.color == "red" else global.white_bishop
			$BaseMove.get_possible_targets = global.get_map().bishop_move
			$BaseMove.settext("Move (bishop)")
			class_skill = global.new_bishop_skill()
		elif spd>=higher and mag<=lower and atk<=lower:
			type = "Knight"
			$Area2D/Sprite.texture = global.black_knight if player.color == "red" else global.white_knight
			class_skill = global.new_knight_skill()
		elif spd>=2*higher and mag>=2*higher and atk>=2*higher:
			type = "Queen"
			$Area2D/Sprite.texture = global.black_queen if player.color == "red" else global.white_queen
			$BaseMove.get_possible_targets = global.get_map().queen_move
			$BaseMove.settext("Move (queen)")
			class_skill = global.new_rook_skill()
			extra_move = global.new_knight_skill()
			extra_skill = global.new_bishop_skill()
			add_child(extra_move)
			add_child(extra_skill)
			extra_move.setowner()
			extra_move.position = Vector2(30,-30)
			extra_move.hide()
			extra_skill.setowner()
			extra_skill.position = Vector2(-30,-30)
			extra_skill.hide()
			all_skills.append(extra_skill)
			all_skills.append(extra_move)
			input_map[KEY_E] = extra_move
			input_map[KEY_Q] = extra_skill
		else:
			$Area2D/Sprite.texture = global.black_pawn if player.color == "red" else global.white_pawn
		
		if type != "Pawn":
			#heal to same percentage
			health = int(float(health)/old_health*get_max_health())
			update_bar()
			all_skills.append(class_skill)
			add_child(class_skill)
			class_skill.setowner()
			class_skill.position = Vector2(-30,0)
			class_skill.hide()
			input_map[KEY_A] = class_skill
	
func _ready():
	attack = 50
	speed = 50
	magic = 50
	
	randomize_stats()
	
	health = get_max_health()
	
	update_bar()
	
	base_move = $BaseMove
	base_attack = $BaseAttack
	
	all_skills = [base_move, base_attack]
	
	for a in all_skills:
		a.hide()
	$StatPage.hide()
	
	input_map = {KEY_W:base_attack, KEY_D: base_move, KEY_A:class_skill}


func highlight_off():
	for a in all_skills:
		a.hide()
		a.visible = false
	$StatPage.hide()
	
func highlight_on(active:=true):
	if active:
		for a in all_skills:
			a.show()
			a.visible = true
	$StatPage.show()

func update_bar():
	$StatPage/ColorRect/VBox/Name.text = str(health)+"/"+str(get_max_health())
	$StatPage/ColorRect/VBox/Grid/ATK2.text = str(get_attack())
	$StatPage/ColorRect/VBox/Grid/MAG2.text = str(get_magic())
	$StatPage/ColorRect/VBox/Grid/SPD2.text = str(get_speed())
	
func heal(amount, color):
	#print("piece healed: ", amount)
	if health+round(amount)<=get_max_health(): 
		health += round(amount)
	else: health = get_max_health()
	update_bar()
	
func damage(amount):
	print("piece damaged: ",amount)
	health -= round(amount)
	update_bar()
	if health<=0: kill()
	$HealTimer.start()

signal piece_killed(coord)

func kill():
	if player!=null:
		var g = global.get_piece_cost(player.color) + added_gold
		player.gain_gold(g*0.6)
	emit_signal("piece_killed", coordinate)

var scorch_chain:=0
func clear_scorch():
	scorch_chain = 0
	$ScorchTimer.stop()
func scorch():
	var mult = 0.09*pow(1.1, scorch_chain)
	print("piece scorched", mult)
	damage(mult*get_max_health())
	if $ScorchTimer.is_stopped(): $ScorchTimer.start()
	scorch_chain+=1


func gain_gold(amount):
	print("gain_gold: ", amount)
	if player != null:
		player.gain_gold(amount)

var added_gold:=0
func add_equip(e:Equipment):
	if e.mag!=0:
		var old_health = get_max_health()
		added_magic += e.mag
		health = int(float(health)/old_health*get_max_health())
	added_attack += e.atk
	added_speed += e.spd

	added_gold = e.cost

	check_evolve()
	update_bar()

remotesync func buy(coord):
	#print(color)
	global.get_map().add_piece_existing(self, coord)

var input_map:Dictionary
func _input(event):
	if event is InputEventKey:
		if event.scancode in input_map:
			var action = input_map[event.scancode]
			if action != null and action.visible:
				action.emit_signal("action_clicked",action)
				get_tree().set_input_as_handled()
		

func _on_Area2D_input_event(viewport, event, shape_idx):
	#print("piece clicked") # Replace with function body.
	pass

func _on_Area2D_mouse_entered():
	$StatPage.show() # Replace with function body.

func _on_Area2D_mouse_exited():
	$StatPage.hide()


func sum(arr):
	var s := 0; for x in arr: s += x; return s

func randomize_stats():
	var sum = attack+magic+speed
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
		
		if s==0: s = - (sign(sum(deltas)))
		if s==0: s = (randi()%2)*2-1
		
		deltas[0] += s
		deltas[1] -= s
	
	deltas.shuffle()
	#print(delta, deltas)
	attack+=deltas[0]; magic+=deltas[1]; speed+=deltas[2]

func _on_HealTimer_timeout():
	heal(get_max_health()*0.025, "")

