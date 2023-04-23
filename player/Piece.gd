class_name Piece extends Node2D

var player:Player = null

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

func check_evolve():
	if type=="Pawn":
		var atk = get_attack(); var mag = get_magic(); var spd = get_speed(); var old_health = get_max_health()
		if atk>=125 and mag <=75 and spd<=75:
			type = "Rook"
			$Area2D/Sprite.texture = global.black_rook if player.color == "red" else global.white_rook
			$BaseMove.get_possible_targets = global.get_map().rook_move
			$BaseMove.settext("Move (rook)")
			$StatPage/ColorRect/VBox/Name.text = "Rook"
			class_skill = global.new_rook_skill()
		elif mag>=125 and atk <=75 and spd<=75:
			type = "Bishop"
			$Area2D/Sprite.texture = global.black_bishop if player.color == "red" else global.white_bishop
			$BaseMove.get_possible_targets = global.get_map().bishop_move
			$BaseMove.settext("Move (bishop)")
			$StatPage/ColorRect/VBox/Name.text = "Bishop"
			class_skill = global.new_bishop_skill()
		elif spd>=125 and mag <=75 and atk<=75:
			type = "Knight"
			$Area2D/Sprite.texture = global.black_knight if player.color == "red" else global.white_knight
			$StatPage/ColorRect/VBox/Name.text = "Knight"
			class_skill = global.new_knight_skill()
		elif spd>=250 and mag>=250 and atk>=250:
			type = "Queen"
			$Area2D/Sprite.texture = global.black_queen if player.color == "red" else global.white_queen
			$BaseMove.settext("Move (queen)")
			$StatPage/ColorRect/VBox/Name.text = "Queen"
		else:
			$Area2D/Sprite.texture = global.black_pawn if player.color == "red" else global.white_pawn
		
		#heal to same percentage
		if type != "Pawn":
			health = int(float(health)/old_health*get_max_health())
			update_bar()
			all_skills.append(class_skill)
			add_child(class_skill)
			class_skill.setowner()
			class_skill.position = Vector2(-30,0)
			class_skill.hide()
	
func _ready():
	#create piece, do all random here
	
	attack = 50
	speed = 50
	magic = 50
	health = get_max_health()
	
	update_bar()
	
	base_move = $BaseMove
	base_attack = $BaseAttack
	
	all_skills = [base_move, base_attack]
	
	for a in all_skills:
		a.hide()
	$StatPage.hide()
	
var disable_selection:=false
func highlight_off():
	for a in all_skills:
		a.hide()
	$StatPage.hide()
func highlight_on():
	if !disable_selection:
		for a in all_skills:
			a.show()
		$StatPage.show()

func update_bar():
	$StatPage/ColorRect/VBox/Name.text = str(health)+"/"+str(get_max_health())
	$StatPage/ColorRect/VBox/Grid/ATK2.text = str(get_attack())
	$StatPage/ColorRect/VBox/Grid/MAG2.text = str(get_magic())
	$StatPage/ColorRect/VBox/Grid/SPD2.text = str(get_speed())
	
func heal(amount):
	print("piece healed: ", amount)
	if health+round(amount)<=get_max_health(): 
		health += round(amount)
	else: health = get_max_health()
	update_bar()
func damage(amount):
	print("piece damaged: ",amount)
	health -= round(amount)
	update_bar()
	if health<=0: kill()

signal piece_killed(coord)

func kill():
	if player!=null:
		pass #gain gold back
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
