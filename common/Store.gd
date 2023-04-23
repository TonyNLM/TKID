extends Control



func _ready():
	restock()
	fix_display()

func fix_display():
	$HBox.rect_position = Vector2(10,0)

var prob_list = [global.new_knight_skill, global.new_rook_skill, global.new_bishop_skill]

func get_sample():
	return prob_list[randi()%prob_list.size()].call_func()

var item_list := []
var count := 7

var shopitem_scene = preload("res://common/ShopItem.tscn")
func restock():
	for i in item_list: 
		remove_child(i)
		i.queue_free()
	
	for n in range(count):
		var new_item = shopitem_scene.instance()
		new_item.child = get_sample()
		$HBox.add_child(new_item)
		

func _on_Restock_timeout():
	restock()
