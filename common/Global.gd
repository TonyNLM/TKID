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

func loadimagetexture(path, size = Vector2(24,24)):
	var t = ImageTexture.new()
	t.create_from_image(load(path))
	t.set_size_override(size)
	return t

func _ready():
	pass


var action = preload("res://actions/Action.tscn")
func new_action() -> Action:
	return action.instance()
	

func new_knight_move():
	var a:Action= new_action()
	a.possible_targets = [Vector2(2,1),Vector2(2,-1), Vector2(-2,-1),Vector2(-2,1), Vector2(2,-1),\
		Vector2(1,-2),Vector2(1,2), Vector2(-1,-2),Vector2(-1,2)]
	a.affected_range = [[Vector2(0,0)]]
	
	return a

