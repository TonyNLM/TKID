extends Control

#TODO: piece price
func _ready():
	add_child(child)
	self.connect("shopitem_clicked",global.get_map(), "shopitem_clicked")
	
	if child is Piece:
		cost['red'] = global.get_piece_cost("red")
		cost["blue"] = global.get_piece_cost("blue")
	
	$RedPrice.text = str(cost["red"])
	$BluePrice.text = str(cost["blue"])

func update_cost():
	if child is Piece:
		cost['red'] = global.get_piece_cost("red")
		cost['blue'] = global.get_piece_cost("blue")
	
	$RedPrice.text = str(cost['red'])
	$BluePrice.text = str(cost['blue'])


var child:Node2D = null

var redcost:int = 100
var bluecost:=100

var cost = {"red":redcost,"blue":bluecost}

func get_cost(color):
	return cost[color]

signal shopitem_clicked(shopitem)
func _on_Button_pressed():
	#print("shopitem clicked")
	emit_signal("shopitem_clicked", self)

func buy(coord, color):
	rpc("buy_item", coord, color)

remotesync func buy_item(coord, color):
	if child is Piece:
		child.color = color
	global.call_group("highlightable","highlight_off")
	global.get_map().players[color].gold -= cost[color]
	child.buy(coord)
	#global.get_map().get_node("PieceStore").update_cost()
	self.queue_free()
