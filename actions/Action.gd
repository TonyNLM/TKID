class_name Action extends Node2D

#array of vec2s, each defining an offset
var possible_targets = [Vector2(1,0),Vector2(0,1),Vector2(-1,0),Vector2(0,-1)]

var penalty: float = 0.17


var base_cooldown: float = 15
func enter_cooldown(speed:int, mult:float=1):
	var speedmult = 1
	if speed < 30: 
		mult = 1.1
	$CD.start(mult * base_cooldown * speedmult)
	$HUD.disable()
	
func _on_CD_timeout():
	$HUD.enable()


func _ready():
	$HUD/Button.connect("pressed",self,"on_Button_clicked")

func settext(t):
	$HUD/EffectPage/VBox/ActionText.action_text = t
	$HUD/EffectPage/VBox/ActionText.setup()


func setup(tarfunc, actfunc, name="Move", text="Move (knight)", text_kws = {},penalty=0.17):
	$HUD/EffectPage.setup(name, text, text_kws)
	
	get_possible_targets = tarfunc
	action_func = actfunc
	penalty = penalty

func setowner():
	piece = get_parent()
	$HUD/EffectPage/VBox/ActionText.setowner(piece)
	
var piece

func get_coord()->Vector2:
	return piece.coordinate

func calculate_values()->Dictionary:
	return $HUD/EffectPage.calculate_values()

#get targets(coord)
var get_possible_targets: FuncRef
#specific tile, takeeffect(self, dest)
var action_func: FuncRef

func takeeffect(dest:Vector2):
	#print("take effect: ", dest)
	action_func.call_func(self, dest)

signal action_clicked(action)
func on_Button_clicked():
	#print("action button clicked:")
	emit_signal("action_clicked",self)

func seticon(icon):
	$HUD/Button.texture_normal = icon
