extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var action_text:String = "Deal <dmg> damage to tiles within range 1."
var action_text_keywords:= {"dmg":"1.5*ATK"}
var belongs_to: Piece = null

func interpret() -> String:
	if belongs_to != null:
		var s = action_text
		var res = calculate_values()
		for key in res:
			s = s.replace("<"+key+">", res[key])
		return s
	else:
		var s = action_text
		for key in action_text_keywords:
			s = s.replace("<"+key+">", action_text_keywords[key])
		return s

func evaluate(command, variable_names = [], variable_values = []):
	var expression = Expression.new()
	var error = expression.parse(command, variable_names)
	if error != OK:
		push_error(expression.get_error_text())
		return

	var result = expression.execute(variable_values, self)

	if not expression.has_execute_failed():
		return result

func calculate_values() -> Dictionary:
	var res = {}
	var names = ["ATK","SPD","MAG","HTH"]
	var vals = [belongs_to.get_attack(), belongs_to.get_speed(), belongs_to.get_magic(), belongs_to.get_max_health()]\
		if belongs_to!=null else [0,0,0,0]
	for key in action_text_keywords:
		res[key] = evaluate(action_text_keywords[key], names, vals)

	return res

var target_size:Vector2 = Vector2(-1,-1)

# Called when the node enters the scene tree for the first time.
func _ready():
	setup(Vector2(80,60)) # Replace with function body.

func setup(tsize = Vector2(-1,-1)):
	$Label.text = interpret()
	
	if tsize != Vector2(-1,-1):
		target_size = tsize

		var err = target_size/($Label.rect_size * rect_scale)
		var relerr = err.x/err.y
				
		if relerr<1.1 && relerr>0.9:
			rect_scale = Vector2(err.x,err.x)
		else:
			rect_scale = err

func setowner(piece):
	belongs_to = piece
	setup()
