extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var player:Player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func setup(p):
	player = p

func _process(delta):

	$ColorRect.border_color = Color(1,0,0) if player.color=="red" else Color(0,0,1)
	
	$VBox/Name.text = player.player_name
	
	$VBox/Grid/HPval.text = str(player.health)+"/"+str(player.max_health)
	var percent = float(player.health)/player.max_health

	$VBox/Grid/HPval.set("custom_colors/font_color",Color.green)
	if percent<.7: $VBox/Grid/HPval.set("custom_colors/font_color",Color(1,1,0))
	if percent<.3: $VBox/Grid/HPval.set("custom_colors/font_color",Color(1,0,0))
	
	$VBox/Grid/Goldval.text = str(player.gold)
		
	$ColorRect.rect_size = $VBox.rect_size
