extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func get_map() -> Node:
	return get_tree().root.get_node("Map")


var WHITE:= Color(1,1,1,1)
var DAMAGE_RED := Color(1,0.3,0.3,1)
var ACTION_BLUE := Color8(50,50,100)
var EQUIP_BROWN := Color8(180,100,50, 180)
var HEALTH_GREEN := Color(0,1,0)

var PLAYER_BLUE := Color(0,0,1)
var PLAYER_RED := Color(1,0,0)

var HIGHLIGHT_YELLOW := Color8(255,255,0,150)
var HIGHLIGHT_BLUE:=Color8(0,0,255,150)

func call_group(group: String, function: String):
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,group,function)

func flip_player(color:String)->String:
	return "blue" if color=="red" else "red"



var white_pawn = loadimagetexture("res://player/white_pawn.png")
var white_knight = loadimagetexture("res://player/white_knight.png")
var white_rook = loadimagetexture("res://player/white_rook.png")
var white_bishop = loadimagetexture("res://player/white_bishop.png")
var white_queen = loadimagetexture("res://player/white_queen.png")

var black_pawn = loadimagetexture("res://player/black_pawn.png")
var black_knight = loadimagetexture("res://player/black_knight.png")
var black_rook = loadimagetexture("res://player/black_rook.png")
var black_bishop = loadimagetexture("res://player/black_bishop.png")
var black_queen = loadimagetexture("res://player/black_queen.png")

var swordicon = preload("res://icons/swordicon.tres")
var booticon = preload("res://icons/booticon.tres")
var healicon = preload("res://icons/healicon.tres")

func loadimagetexture(path, size = Vector2(24,24)):
	var t = ImageTexture.new()
	t.create_from_image(load(path))
	t.set_size_override(size)
	return t

func win_game(color):
	print("Player ",color," wins!")




	
var action_scene = preload("res://actions/Action.tscn")
func new_action() -> Action:
	var a = action_scene.instance()
	#a.connect("action_clicked",get_map(),"action_clicked")
	return a
	
func new_bishop_skill() -> Action:
	var a := new_action()
	a.setup(get_map().self_adj, "heal", "Heal", "Heal <heal_p> to Pieces and <heal_l> to land in 8 adj tiles",
	 {"heal_p":"25+0.75*MAG", "heal_l":"(25+0.75*MAG)/HLTH"})
	a.penalty = 0.2
	a.base_cooldown = 20
	a.seticon(healicon)
	return a
var new_bishop_skill = funcref(self, "new_bishop_skill")
func new_knight_skill() -> Action:
	var a := new_action()
	a.setup(get_map().knight_move, "move_snipe", "Quick Attack", "Move and then deal <dmg> damage to adjacent tiles",
		{"dmg":"10+0.6*ATK"})
	a.base_cooldown = 20
	a.seticon(booticon)
	return a
var new_knight_skill = funcref(self,"new_knight_skill")
func new_rook_skill() -> Action:
	var a := new_action()
	a.setup(get_map().adj_3_tiles, "attack", "Slash", "Deal <dmg> Damage to 3 tiles in 1 direction",{"dmg":"50+0.5*ATK"})
	a.penalty = 0.23
	a.base_cooldown = 25
	a.seticon(swordicon)
	return a
var new_rook_skill = funcref(self,"new_rook_skill")


var equipscene = preload("res://common/Equipment.tscn")
func new_equip() -> Equipment:
	return equipscene.instance()
	
func new_general() -> Equipment:
	var e := new_equip()
	e.setstats(20,20,20)
	return e
var new_general = funcref(self,"new_general")
func new_attack() -> Equipment:
	var e := new_equip()
	e.setstats(30,10,10)
	return e
var new_attack = funcref(self,"new_attack")
func new_magic() -> Equipment:
	var e := new_equip()
	e.setstats(10,30,10)
	return e
var new_magic = funcref(self,"new_magic")
func new_speed() -> Equipment:
	var e := new_equip()
	e.setstats(10,10,30)
	return e
var new_speed = funcref(self,"new_speed")
func new_attack1() -> Equipment:
	var e := new_equip()
	e.setstats(40,0,0)
	return e
var new_attack1 = funcref(self,"new_attack1")
func new_magic1() -> Equipment:
	var e := new_equip()
	e.setstats(0,40,0)
	return e
var new_magic1 = funcref(self,"new_magic1")
func new_speed1() -> Equipment:
	var e := new_equip()
	e.setstats(0,0,40)
	return e
var new_speed1 = funcref(self,"new_speed1")

var piecescene = preload("res://player/Piece.tscn")
func new_piece() -> Piece:
	var p:Piece = piecescene.instance()
	p._ready()
	p.base_move.setup(get_map().knight_move, "move_piece")
	p.base_move.penalty = 0.05
	p.base_move.connect("action_clicked", self, "action_clicked")
	p.base_move.seticon(global.booticon)
	
	p.base_attack.setup(get_map().get_dist1,"attack_mine","Attack/Mine",
		"Deal <dmg> Damage /Mine <dmg> to a tile within range 1",{"dmg":"30+0.5*ATK"})
	p.base_attack.connect("action_clicked",self,"action_clicked")
	p.base_attack.seticon(global.swordicon)

	for a in p.all_skills:
		a.setowner()
	return p
var new_piece = funcref(self,"new_piece")


var action_shop = [new_bishop_skill,new_knight_skill,new_rook_skill]
var equip_shop = [new_general,new_attack,new_magic,new_speed,new_attack1,new_magic1,new_speed1]
var piece_shop = [new_piece]

func get_piece_cost(color) -> int:
	var count = len(get_map().all_pieces[color])
	count += 1
	count *= 2
	return count*count*10
