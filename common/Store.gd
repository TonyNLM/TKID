extends Control



func _ready():
	restock()
	fix_display()

func fix_display():
	$HBox.rect_position = Vector2(10,0)


var prob_list:Array=global.action_shop

func get_sample():
	return prob_list[randi()%prob_list.size()].call_func()

var count := 7

var shopitem_scene = preload("res://common/ShopItem.tscn")
func restock():
	for i in $HBox.get_children():
		$HBox.remove_child(i)
		
	for n in range(count):
		var new_item = shopitem_scene.instance()
		new_item.child = get_sample()
		$HBox.add_child(new_item)
		

func _on_Restock_timeout():
	#print("restock")
	restock()

func update_cost():
	for i in $HBox.get_children():
		i.update_cost()


func _on_Button_pressed():
	restock()
