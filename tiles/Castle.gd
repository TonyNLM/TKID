class_name Castle extends Tile


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var belongs_to = null

func setowner(player):
	belongs_to = player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

#overriden parent functions
func scorch(amount):
	pass
func is_scorched()->bool:
	return false
func heal(amount):
	pass
func reset_chain():
	pass

func damage(amount):
	belongs_to.damage(amount)


func highlight_on(color=null):
	if color!=null:
		$highlight.color = color
	$highlight.visible = true


var last_clicked:Vector2 = Vector2(1,1)
func _on_Tile_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		
		var offset = $CastleBlue.world_to_map($CastleBlue.to_local(event.position))
		emit_signal("tile_clicked", coord+offset)
