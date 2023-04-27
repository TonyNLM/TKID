class_name City extends Tile


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var control := {"red":0,"blue":0}
var win_threshold := 1500
var gain_thresholds = [500,1000]


func heal(amount, color:String):
	var otherplayer=global.flip_player(color)
	control[otherplayer] -= amount
	if control[otherplayer]<0: control[otherplayer] = 0
	print("control of player: ",global.flip_player(color)," decreased by ",amount)

#overriden parent functions
func scorch(amount):
	pass
func is_scorched()->bool:
	return false
func reset_chain():
	pass
func heal_scorch(amount):
	pass


func damage(amount, color):
	control[color] += amount
	print("control of player: ",color," increased by ",amount)
	if control[color]>win_threshold:
		global.win_game(color)

func highlight_off():
	$highlight.hide()
func highlight_on(color=null):
	if color!=null:
		$highlight.color = color
	$highlight.visible = true


func _on_Tile_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		var offset = $CastleGray.world_to_map($CastleGray.to_local(event.position))
		emit_signal("tile_clicked", coord+offset)
