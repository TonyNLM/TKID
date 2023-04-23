extends Node2D	

var cell_size:int = 24

var map_size = Vector2(32,30)
var tiles: Array = []
var occupied: Array = []

var active_player = null
func set_active_player(color):
	active_player = players[color]

var all_pieces:={"red":[],"blue":[]}



var tilescene = preload("res://tiles/Tile.tscn")
func add_tile(x,y,type):
	tiles[x][y] = tilescene.instance()
	add_child(tiles[x][y])
	tiles[x][y].setup(x,y,cell_size,type)

	get_tile(Vector2(x,y)).connect("tile_clicked",self,"tile_clicked")
	get_tile(Vector2(x,y)).connect("fully_scorched",self,"on_tile_scorched")
	get_tile(Vector2(x,y)).connect("healed",self,"on_tile_healed")

var piecescene = preload("res://player/Piece.tscn")
# new_piece function!!!
func add_piece(x,y, color="blue"):
	var p = piecescene.instance()
	occupied[x][y] = p
	add_child(p)
	
	p.coordinate = Vector2(x,y)
	p.position = Vector2(x,y)*cell_size
	
	p.connect("piece_killed",self,"on_piece_killed")
	
	#action shit
	p.base_move.setup(knight_move, "move_piece")
	p.base_move.penalty = 0.05
	p.base_move.connect("action_clicked", self, "action_clicked")
	p.base_move.seticon(global.booticon)
	
	p.base_attack.setup(get_dist1,"attack_mine","Attack/Mine",
		"Deal <dmg> Damage /Mine <dmg> to a tile within range 1",{"dmg":"30+0.5*ATK"})
	p.base_attack.connect("action_clicked",self,"action_clicked")
	p.base_attack.seticon(global.swordicon)

	for a in p.all_skills:
		a.setowner()
		
	p.player = players[color]
	p.check_evolve()
	
	all_pieces[color].append(p)
	
var castlescene = preload("res://tiles/Castle.tscn")
func add_castle(x,y,color="blue"):
	var coord = Vector2(x,y)
	if get_tile(coord)==null:
		var c = castlescene.instance()
		tiles[x][y] = c
		tiles[x+1][y] = c
		tiles[x][y+1] = c
		tiles[x+1][y+1] = c
		add_child(c)

		c.coord = coord
		c.position = coord*cell_size
		c.cellsize = cell_size
		c.type = "Castle"
		
		match color:
			"blue": c.get_node("CastleBlue").show()
			"red": c.get_node("CastleRed").show()
		c.setowner(players[color])
		
		get_tile(Vector2(x,y)).connect("tile_clicked",self,"tile_clicked")

var players:={}
var id2color := {1:"red",2:"blue"}

func _ready():
	tiles.resize(map_size.x)
	occupied.resize(map_size.x)
	for x in range(tiles.size()):
		tiles[x] = []
		tiles[x].resize(map_size.y)
		occupied[x] = []
		occupied[x].resize(map_size.y)
	
	players["red"] = $PlayerRed
	players["blue"] = $PlayerBlue

	$PlayerRed.color = "red"; $PlayerBlue.color = "blue"
	$PlayerRed.player_name = "Red"; $PlayerBlue.player_name = "Blue"
	
	#load_map()
	#demo()
	
	
	
func demo():
	add_piece(6,6,"red")
	add_piece(23,23)

	add_piece(7,7, "red")
	add_piece(22,22)
	
	get_piece(Vector2(7,7)).magic = 125
	get_piece(Vector2(7,7)).heal(5000)
	get_piece(Vector2(7,7)).check_evolve()
	get_piece(Vector2(22,22)).magic = 125
	get_piece(Vector2(22,22)).heal(5000)
	get_piece(Vector2(22,22)).check_evolve()
	
	add_piece(6,7, "red")
	add_piece(23,22)
	
	get_piece(Vector2(6,7)).attack = 125
	get_piece(Vector2(6,7)).check_evolve()
	get_piece(Vector2(23,22)).attack = 125
	get_piece(Vector2(23,22)).check_evolve()

	add_piece(7,6,"red")
	add_piece(22,23)

	get_piece(Vector2(7,6)).speed = 125
	get_piece(Vector2(7,6)).check_evolve()
	get_piece(Vector2(22,23)).speed = 125
	get_piece(Vector2(22,23)).check_evolve()



func load_map(path = "res://map.txt"):
	var file = File.new()
	file.open(path, file.READ)
	var y = 0
	var x = 0
	while not file.eof_reached():
		var line = file.get_csv_line()
		#print(line)
		x = 0
		for type in line:
			match type:
				"f","F","":
					add_tile(x,y,"Floor")
				"w","W":
					add_tile(x,y,"Wall")
				"g","G":
					add_tile(x,y,"Gold")
				"Cb":
					add_castle(x,y,"blue")
				"Cr":
					add_castle(x,y,"red")
			x+=1
		y += 1
	map_size = Vector2(x,y)
	file.close()

func can_travel(coord:Vector2) -> bool:
	return get_tile(coord).can_travel && get_piece(coord) == null && coord>=Vector2(0,0) && coord < map_size
func is_floor(coord:Vector2)->bool:
	return get_tile(coord).type=="Floor"
func is_occupied(coord:Vector2)->bool:
	return get_piece(coord)!=null
func in_bounds(coord:Vector2)->bool:
	return coord.x>=0 and coord.y>=0 && coord.x < map_size.x and coord.y< map_size.y

func get_tile(coord:Vector2) -> Tile:
	return tiles[coord.x][coord.y]

func get_piece(coord:Vector2) -> Piece:
	return occupied[coord.x][coord.y]

func can_damage(coord:Vector2):
	if get_piece(coord)!=null:
		return get_piece(coord)
	if get_tile(coord).type=="Castle":
		return get_tile(coord)
	return null

func next_to_mine(coord:Vector2):
	return false

#called before any tile-specific input events
func _unhandled_input(event):
	if (event is InputEventMouseButton && event.pressed):
		global.call_group("highlightable", "highlight_off")
	
	
var selected_coordinates: Dictionary
var selected_action:Action = null
var selected_origin: Vector2
var selected_shopitem = null

func reset_selection():
	selected_action = null
	selected_coordinates = {}
	selected_shopitem = null

func tile_clicked(coord:Vector2):
	#print("tile clicked entered")

	if selected_action == null:
		if selected_shopitem == null:
			#not a target selection, highlight only
			get_tile(coord).highlight_on()
			if get_piece(coord) != null:
				if get_piece(coord).player.color==active_player.color:
					get_piece(coord).highlight_on()
					selected_origin = coord
		else:
			#bought from shop successfully
			selected_origin = coord
			selected_shopitem.buy(coord)
			
	else:
		#carry out action
		var piece = get_piece(selected_origin)
		if piece != null and coord in selected_coordinates:
			var queue:Array = selected_coordinates[coord]
			
			for target in queue:
				rpc(selected_action.action_func, selected_action, target)
				#selected_action.takeeffect(target)
			scorch_land(selected_origin, selected_action.penalty)
			
			if selected_action.oneshot: selected_action.queue_free()
			#DEBUG: no cd
			#selected_action.enter_cooldown(piece.speed)
			
		reset_selection()

func action_clicked(action: Action):
	reset_selection()
	var res = action.get_possible_targets.call_func(selected_origin)
	var dests:Array = res[0]; var dest_targets = res[1]

	global.call_group("highlightable", "highlight_off")

	if dests.size()>0:
		for dest in dests:
			selected_coordinates[dest] = [dest] if dest_targets==null else dest_targets[dest]
			for target in selected_coordinates[dest]:
				get_tile(target).highlight_on(global.HIGHLIGHT_YELLOW)
		
		for dest in dests:
			print(dest)
			get_tile(dest).highlight_on(global.HIGHLIGHT_BLUE)
		
		selected_action = action

func shopitem_clicked(shopitem):
	#print("shopitem clicked")
	reset_selection()
	if active_player.gold < shopitem.cost: return
	
	selected_shopitem = shopitem
	if shopitem.child is Piece:
		print("piece")
	if shopitem.child is Action:
		shopitem.child.oneshot = true
		for p in all_pieces[active_player.color]:
			selected_coordinates[p.coordinate] = null
		for coord in selected_coordinates:
			get_tile(coord).highlight_on(global.HIGHLIGHT_BLUE)
		
		

func on_tile_scorched(coord:Vector2):
	var p = get_piece(coord)
	if p!=null:
		p.scorch()
	
func on_tile_healed(coord:Vector2):
	pass

func on_piece_killed(coord:Vector2):
	var p := get_piece(coord)
	occupied[coord.x][coord.y] = null
	all_pieces[p.player.color].erase(p)
	p.queue_free()


remotesync func move_piece(action:Action, dest):
	var origin = action.get_coord()
	var penalty = action.penalty
	
	var p := get_piece(origin)
	if p==null: return
	
	if !get_tile(dest).is_scorched():
		p.clear_scorch()
		
	if can_travel(dest):
		occupied[origin.x][origin.y] = null
		occupied[dest.x][dest.y] = p
		
		p.coordinate = dest
		p.position = dest*cell_size
	
		scorch_land(dest, penalty)

remotesync func damage_land(dest, amount):
	var porc = can_damage(dest)
	porc.damage(amount)	
	
remotesync func scorch_land(dest, amount):
	get_tile(dest).scorch(amount)
	
remotesync func damage_scorch(dest, damage, scorch):
	damage_land(dest, damage)
	scorch_land(dest,scorch)

remotesync func mine_land(piece:Piece, dest, amount, scorch):
	scorch_land(dest,scorch)
	if next_to_mine(dest):
		amount = amount*1.3
	piece.gain_gold(amount)

remotesync func attack_mine(action:Action, dest):
	var dmg = action.calculate_values()["dmg"]
	var penalty = action.penalty
	if can_damage(dest) != null:
		damage_scorch(dest, dmg,penalty)
	else:
		mine_land(action.piece,dest,dmg,penalty)

remotesync func attack(action: Action, dest):
	var dmg = action.calculate_values()["dmg"]
	var penalty = action.penalty
	
	if can_damage(dest) != null:
		damage_land(dest, dmg)
	scorch_land(dest,penalty)

remotesync func move_snipe(action:Action, dest):
	var dmg = action.calculate_values()["dmg"]
	var penalty = action.penalty
	move_piece(action, dest)
	var origin = dest
	for dest in get_dist1(origin)[0]:
		if can_damage(dest) != null:
			damage_land(dest, dmg)
		scorch_land(dest,penalty)

remotesync func heal_land(dest, amount):
	get_tile(dest).heal(amount)

remotesync func heal(action: Action, dest):
	var params = action.calculate_values()
	var heal = params["heal_p"]
	var healland = params["heal_l"]

	if can_damage(dest) != null:
		can_damage(dest).heal(heal)

	heal_land(dest, healland)




func merge_action_targets(res1, res2):
	var targets = res1[0]
	var steps = res1[1]
	
	var temp = []
	for dest in res2[0]:
		if not dest in targets: temp.append(dest)
	targets.append_array(temp)
	
	var othersteps = res2[1]
	for dest in temp:
		steps[dest] = [dest] if othersteps== null else othersteps[dest]

	return [targets,steps]

func compose_action_targets(origin: Vector2, func1:FuncRef, func2:FuncRef):
	var origins:Array = func1.call_func(origin)[0]
	var res = origins.duplicate(true)
	var steps = {}
	for dest in origins:
		steps[dest] = func2.call_func(dest)[0]
	return [res, steps]

func get_knight_move(coord:Vector2, flooronly:=true):
	var res = []
	for offset in [Vector2(2,1),Vector2(2,-1), Vector2(-2,-1),Vector2(-2,1), Vector2(2,-1),\
		Vector2(1,-2),Vector2(1,2), Vector2(-1,-2),Vector2(-1,2)]:
		var new_coord = coord+offset
		if in_bounds(new_coord) and !is_occupied(new_coord) and (!flooronly or is_floor(new_coord)):
			print("inbounds", new_coord, " ", in_bounds(new_coord))
			res.append(new_coord)
	return [res,null]
var knight_move = funcref(self,"get_knight_move")
func get_rook_move(coord:Vector2, flooronly:=true):
	var res =[]
	var queues = {}
	for dir in [Vector2(1,0),Vector2(0,1),Vector2(-1,0),Vector2(0,-1)]:
		var queue = []
		for i in range(1,5):
			var new_coord = coord+dir*i
			if in_bounds(new_coord) and !is_occupied(new_coord) and (!flooronly or is_floor(new_coord)):
				res.append(new_coord)
				queue.append(new_coord)
				queues[new_coord] = queue.duplicate(true)
			else: break			
	return [res,queues]
var rook_move = funcref(self,"get_rook_move")
func get_bishop_move(coord:Vector2, flooronly:=true):
	var res =[]
	var queues = {}
	for dir in [Vector2(1,1),Vector2(-1,1),Vector2(1,-1),Vector2(-1,-1)]:
		var queue = []
		for i in range(1,5):
			var new_coord = coord+dir*i
			if in_bounds(new_coord) and !is_occupied(new_coord) and (!flooronly or is_floor(new_coord)):
				res.append(new_coord)
				queue.append(new_coord)
				queues[new_coord] = queue.duplicate(true)
			else: break			
	return [res,queues]
var bishop_move = funcref(self,"get_bishop_move")
func get_queen_move(coord:Vector2):
	var res = get_rook_move(coord)
	var bres = get_bishop_move(coord)
	var cres = merge_action_targets(res,bres)
	return merge_action_targets(cres, get_knight_move(coord))
var queen_move = funcref(self,"get_queen_move")

func get_dist0(coord:Vector2, flooronly:=false):
	var res = []
	if in_bounds(coord) and (!flooronly or is_floor(coord)):
		res.append(coord)
	return [res,null]
var get_dist0 = funcref(self,"get_dist0")
func get_dist1(coord:Vector2, flooronly:=false):
	var res = []
	for offset in [Vector2(1,0),Vector2(0,1),Vector2(-1,0),Vector2(0,-1)]:
		var target = coord+offset
		if in_bounds(target) and (!flooronly or is_floor(target)):
			res.append(target)
	return [res,null]
var get_dist1 = funcref(self,"get_dist1")
func get_dist2(coord:Vector2,flooronly:=false):
	var res = []
	for offset in [Vector2(2,0),Vector2(0,2),Vector2(-2,0),Vector2(0,-2),\
	Vector2(1,1),Vector2(1,-1),Vector2(-1,-1),Vector2(-1,1)]:
		var target = coord+offset
		if in_bounds(target) and (!flooronly or is_floor(target)):
			res.append(target)
	return [res,null]
var get_dist2 = funcref(self,"get_dist2")

#8 tiles
func get_adj(coord:Vector2, flooronly:=false):
	var res = []
	for offset in [Vector2(1,0),Vector2(0,1),Vector2(-1,0),Vector2(0,-1),\
	Vector2(1,1),Vector2(1,-1),Vector2(-1,-1),Vector2(-1,1)]:
		var target = coord+offset
		if in_bounds(target) and (!flooronly or is_floor(target)):
			res.append(target)
	return [res,null]
var get_adj = funcref(self,"get_adj")
func get_2_adj(coord:Vector2, flooronly:=false):
	var res = []
	for offset in [Vector2(2,0),Vector2(0,2),Vector2(-2,0),Vector2(0,-2),\
	Vector2(2,2),Vector2(2,-2),Vector2(-2,-2),Vector2(-2,2)]:
		var target = coord+offset
		if in_bounds(target) and (!flooronly or is_floor(target)):
			res.append(target)
	return [res,null]
var get_2_adj = funcref(self,"get_2_adj")


func self_adj(origin:Vector2, flooronly := false):
	return compose_action_targets(origin, get_dist0, get_adj)
var self_adj = funcref(self,"self_adj")
func knight_move_adj(origin:Vector2):
	return compose_action_targets(origin, knight_move, get_dist1)
var knight_move_adj = funcref(self,"knight_move_adj")
func adj_3_tiles(origin:Vector2, flooronly:=false):
	var ressteps = get_dist1(origin, flooronly); ressteps[1] = {}
	var perp_vecs = {Vector2(0,1):Vector2(1,0),Vector2(1,0):Vector2(0,1)}
	for dest in ressteps[0]:
		var vec = origin-dest
		var perp = perp_vecs[vec] if vec in perp_vecs else perp_vecs[-vec]
		ressteps[1][dest] = [dest+perp, dest, dest-perp, dest-vec]
	return ressteps
var adj_3_tiles = funcref(self,"adj_3_tiles")
