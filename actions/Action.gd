class_name Action extends Node2D

#array of vec2s, each defining an offset
var possible_targets = [Vector2(1,0),Vector2(0,1),Vector2(-1,0),Vector2(0,-1)]

var penalty: float = 0.17


var base_cooldown: float = 15.0
func enter_cooldown(speed:int, mult:float=1.0):
	var ah = (speed-50)/100.0
	var speedmult = 1.0/ (ah+1)
	if speed < 30: 
		speedmult = 1.25
	$CD.start(mult * base_cooldown * speedmult)
	$HUD.disable()
	
func _on_CD_timeout():
	$HUD.enable()


func _ready():
	$HUD/Button.connect("pressed",self,"on_Button_clicked")

func settext(t):
	$HUD/EffectPage/VBox/ActionText.action_text = t
	$HUD/EffectPage/VBox/ActionText.setup()


func setup(tarfunc, actfunc, name="Move", text="Move (knight)", text_kws = {}):
	$HUD/EffectPage.setup(name, text, text_kws)
	
	get_possible_targets = tarfunc
	action_func = actfunc

func setowner():
	piece = get_parent()
	$HUD/EffectPage/VBox/ActionText.setowner(piece)
	self.connect("action_clicked", global.get_map(), "action_clicked")
	
var piece = null

func get_coord()->Vector2:
	return piece.coordinate

func calculate_values()->Dictionary:
	return $HUD/EffectPage.calculate_values()

#get targets(coord)
var get_possible_targets: FuncRef
#specific tile, takeeffect(self, dest)
var action_func: String

signal action_clicked(action)
func on_Button_clicked():
	#print("action button clicked:")
	emit_signal("action_clicked",self)

func seticon(icon):
	$HUD/Button.texture_normal = icon


var oneshot := false

remotesync func buy(coord:Vector2):
	var p = global.get_map().get_piece(coord)
	get_parent().remove_child(self)
	p.add_child(self)
	setowner()
	
	emit_signal("action_clicked",self)






