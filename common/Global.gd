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
var bowicon = preload("res://icons/bowicon.tres")
var fireballicon = preload("res://icons/fireballicon.tres")
var flamethrowicon = preload("res://icons/flamethrowicon.tres")
var stunicon = preload("res://icons/stunicon.tres")
var shovelicon = preload("res://icons/shoveicon.tres")
var grenadeicon = preload("res://icons/grenadeicon.tres")
var wallicon = preload("res://icons/wallicon.tres")

var bookicon = preload("res://icons/bookicon.tres")
var armoricon = preload("res://icons/armoricon.tres")

func loadimagetexture(path, size = Vector2(24,24)):
	var t = ImageTexture.new()
	t.create_from_image(load(path))
	t.set_size_override(size)
	return t

func win_game(color:String):
	get_map().get_node("Win").text = "Player "+color.to_upper()+" wins!!"
	get_map().get_node("Win").set("custom_colors/font_color", PLAYER_RED if color=="red" else PLAYER_BLUE)
	get_map().get_node("Win").show()
	
var action_scene = preload("res://actions/Action.tscn")
func new_action() -> Action:
	var a = action_scene.instance()
	return a
	
func new_bishop_skill() -> Action:
	var a := new_action()
	a.setup(get_map().self_adj, "heal", "Heal", "Heal <heal_p> to Pieces and <heal_l> to land in 8 adj tiles",
	 {"heal_p":"25+0.75*MAG", "heal_l":"(25+0.75*MAG)/HLTH"})
	a.penalty = 0.2
	a.base_cooldown = 20
	a.seticon(healicon)
	a.cost = 220
	return a
var new_bishop_skill = funcref(self, "new_bishop_skill")
func new_knight_skill() -> Action:
	var a := new_action()
	a.setup(get_map().knight_move, "move_snipe", "Quick Attack", "Move and then deal <dmg> damage to adjacent tiles",
		{"dmg":"0.3*ATK+0.35*SPD"})
	a.base_cooldown = 20
	a.seticon(booticon)
	a.cost = 160
	return a
var new_knight_skill = funcref(self,"new_knight_skill")
func new_rook_skill() -> Action:
	var a := new_action()
	a.setup(get_map().adj_3_tiles, "attack", "Slash", "Deal <dmg> Damage to 3 tiles in 1 direction",{"dmg":"50+0.5*ATK"})
	a.penalty = 0.23
	a.base_cooldown = 15
	a.seticon(swordicon)
	a.cost = 180
	return a
var new_rook_skill = funcref(self,"new_rook_skill")

#scale with mag and atk, straight3, c300, p0.27
func new_fireball()-> Action:
	var a := new_action()
	a.setup(get_map().get_fireball, "attack", "Fireball", "Deal <dmg> Damage to 9 tiles",{"dmg":"20 + 0.75*MAG + 0.45*ATK"})
	a.penalty = 0.33
	a.seticon(fireballicon)
	a.cost = 250
	return a
var new_fireball = funcref(self,"new_fireball")

#c75, 
func new_basemove()-> Action:
	var a :=new_action()
	a.setup(get_map().knight_move, "move_piece")
	a.penalty = 0.05
	a.seticon(global.booticon)
	a.cost = 75
	return a
var new_basemove = funcref(self,"new_basemove")
#c50, p0.05
func new_sidestep()-> Action:
	var a :=new_action()
	a.setup(get_map().get_dist1, "move_piece", "Sidestep", "Move (adjacent)")
	a.penalty = 0.05
	a.seticon(global.booticon)
	a.cost = 50
	return a
var new_sidestep = funcref(self,"new_sidestep")

#straight line, c150 p0.27, [0.2,0.16,.128,.1,.08] (twice)
func new_flamethrow()-> Action:
	var a := new_action()
	a.setup(get_map().get_flamethrow, "flamethrow", "Flamethrowing", "Scorch <scorch> to tiles twice, less the further it goes",
		{"scorch":"0.05 + 0.001*MAG + 0.001*SPD"})
	a.penalty = 0.29
	a.seticon(flamethrowicon)
	a.cost = 170
	return a
var new_flamethrow = funcref(self,"new_flamethrow")

#scale with speed and atk, c200, p0.15
func new_arrow()-> Action:
	var a := new_action()
	a.setup(get_map().get_man_4, "attack", "Snipe", "Deal <dmg> to a remote tile",
		{"dmg":"5 + 0.6*SPD + 0.5*ATK"})
	a.penalty = .15
	a.seticon(bowicon)
	a.cost = 200
	return a
var new_arrow = funcref(self,"new_arrow")

#c200, p0.21
func new_stun()-> Action:
	var a := new_action()
	a.setup(get_map().get_adj_piece, "stun", "Stun", "Reset all cooldown of a nearby piece with a <mult> multiplier", 
		{"mult":"0.5 + 0.0025*MAG + 0.001*SPD"})
	a.penalty = .21
	a.seticon(stunicon)
	a.cost = 200
	return a
var new_stun = funcref(self,"new_stun")

#cost 400, p0.5
func new_mine()-> Action:
	var a := new_action()
	a.setup(get_map().self_adj, "mine", "Mine", "Mine <amt> in all adjacent tiles",
		{"amt":"5 + 0.2*ATK + 0.2*SPD + 0.2*MAG"})
	a.penalty = .5
	a.seticon(shovelicon)
	a.cost = 450
	return a
var new_mine = funcref(self,"new_mine")

#c1000, p0.7
func new_wall()-> Action:
	var a := new_action()
	a.setup(get_map().get_adj_floor, "wall", "Wall", "Build a wall")
	a.penalty = .66
	a.seticon(wallicon)
	a.cost = 900
	return a
var new_wall = funcref(self,"new_wall")

#c250, p 0.5. destroys wall.
func new_grenade()-> Action:
	var a := new_action()
	a.setup(get_map().get_dist1, "grenade", "Grenade", "Deal <dmg> damage to adjacent tiles, destroys walls",
		{"dmg":"0.5*HLTH + 0.5*ATK"})
	a.penalty = 0.47
	a.seticon(grenadeicon)
	a.cost = 250
	return a
var new_grenade = funcref(self,"new_grenade")


var equipscene = preload("res://common/Equipment.tscn")
func new_equip() -> Equipment:
	return equipscene.instance()
	
func new_general() -> Equipment:
	var e := new_equip()
	e.setstats(20,20,20)
	e.seticon(armoricon)
	return e
var new_general = funcref(self,"new_general")
func new_attack() -> Equipment:
	var e := new_equip()
	e.setstats(30,10,10)
	e.seticon(swordicon)
	return e
var new_attack = funcref(self,"new_attack")
func new_magic() -> Equipment:
	var e := new_equip()
	e.setstats(10,30,10)
	e.seticon(bookicon)
	return e
var new_magic = funcref(self,"new_magic")
func new_speed() -> Equipment:
	var e := new_equip()
	e.setstats(10,10,30)
	e.seticon(booticon)
	return e
var new_speed = funcref(self,"new_speed")
func new_attack1() -> Equipment:
	var e := new_equip()
	e.setstats(40,0,0)
	e.seticon(swordicon)
	e.setcolor(DAMAGE_RED)
	return e
var new_attack1 = funcref(self,"new_attack1")
func new_magic1() -> Equipment:
	var e := new_equip()
	e.setstats(0,40,0)
	e.seticon(bookicon)
	e.setcolor(DAMAGE_RED)
	return e
var new_magic1 = funcref(self,"new_magic1")
func new_speed1() -> Equipment:
	var e := new_equip()
	e.setstats(0,0,40)
	e.seticon(booticon)
	e.setcolor(DAMAGE_RED)
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


var action_shop = [new_bishop_skill,new_knight_skill,new_rook_skill,new_arrow,new_basemove,new_fireball,new_flamethrow,new_grenade,new_mine,new_sidestep,new_stun,new_wall]
var equip_shop = [new_general,new_attack,new_magic,new_speed,new_attack1,new_magic1,new_speed1]
var piece_shop = [new_piece]

func get_piece_cost(color) -> int:
	var count = len(get_map().all_pieces[color])
	count += 1
	count *= 2
	return count*count*10

var random:RandomNumberGenerator = newrandom()
func newrandom():
	var r = RandomNumberGenerator.new()
	r.seed = 0
	return r
