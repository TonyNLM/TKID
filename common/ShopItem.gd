extends Control

#TODO: piece price
func _ready():
	add_child(child)
	self.connect("shopitem_clicked",global.get_map(), "shopitem_clicked")
	$RedPrice.text = str(cost)
	$BluePrice.text = str(cost)
	$Button.mouse_filter = 1

var child:Node2D = null
var cost:int = 100


signal shopitem_clicked(shopitem)


func _on_Button_pressed():
	#print("shopitem clicked")
	emit_signal("shopitem_clicked", self)

func buy(coord):
	rpc("buy_item", coord)

remotesync func buy_item(coord):
	child.buy(coord)
	self.queue_free()
