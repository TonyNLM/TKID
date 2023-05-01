tool
extends EditorScript

var img

func _run():
	var map = Map.new("testing")
	var simplex = Simplex.new(3,5,0.5)

	map.generate(simplex)
	map.to_file("testing")

	
	map.add_goldmines()
	map.to_file("testing_gold")
	
	map.transform_map()
	map.to_file("testing_trans")

	map.bishop_pathways()

	map.make_symmetric()
	map.to_file("testing_sym")
	
	map.add_castle()
	map.add_city()
	map.add_piece()
	
	map.to_file("testing_cast")


	map = Map.new("prim")
	var prim = Prim.new()
	
	map.generate(prim)
	map.to_file("prim")
	
	map.add_goldmines()
	map.to_file("prim_gold")
	
	map.transform_map()
	map.to_file("prim_trans")
	
	map.bishop_pathways()

	map.make_symmetric()
	map.to_file("prim_sym")
	
	map.add_castle()
	map.add_city()
	map.add_piece()
	
	map.to_file("prim_cast")
	

class Simplex:
	var noise
	func _init(oct:=4,period:=7.5,pers:=0.5):
		noise = OpenSimplexNoise.new()
		noise.octaves = oct
		noise.period = period
		noise.persistence = pers
		
	func generate(seedstr:String, size:Vector2, floorprob:float)->Array:
		noise.seed = seedstr.hash()
		seed(seedstr.hash())
		
		var generated = []
		generated.resize(size.x)
		for x in range(size.x):
			generated[x] = []
			generated[x].resize(size.y)

		for x in range(size.x):
			for y in range(size.y):
				#introduce a bit of randomness to the grid
				var r = 0.1
				var nx = x+ r*rand_range(-1,1)
				var ny = y+ r*rand_range(-1,1)
				generated[x][y] = noise.get_noise_2d(nx,ny)
				
		return generated


class Map:
	var generated:Array
	var seedstr:String
	var mapsize:Vector2
	var threshold:=0.0
	
	func _init(mapseed:="", size := Vector2(30,30), floorprob:=0.5):
		seedstr = mapseed; mapsize=size; threshold = floorprob*2-1
	
	func setcoord(coord:Vector2, type:String):
		if in_bounds(coord):
			generated[coord.x][coord.y] = type

	func setfloor(coord,prob): if randf()<prob: setcoord(coord,"F") 
	func setwall(coord,prob): if randf()<prob: setcoord(coord,"W") 
	func setgold(coord,prob): if randf()<prob: setcoord(coord,"G") 

	func get_tile(coord:Vector2):
		return generated[coord.x][coord.y]

	func in_bounds(coord:Vector2)->bool:
		return coord.x>=0 and coord.y>=0 && coord.x < mapsize.x and coord.y< mapsize.y
	func is_edge(coord:Vector2):return coord.x==0 or coord.y==0 or coord.x==mapsize.x-1 or coord.y==mapsize.y-1

	func generate(generator):
		var g = generator.generate(seedstr, mapsize, (threshold+1)/2.0)

		for x in range(mapsize.x):
			for y in range(mapsize.y):
				g[x][y] = "F" if g[x][y]<threshold else "W"
		generated = g


	func get_castle_adj(coord:Vector2)->Array:
		var res = []
		for offset in[Vector2(0,-1),Vector2(1,-1),Vector2(2,0),\
			Vector2(2,1),Vector2(1,2),Vector2(0,2),Vector2(-1,1),Vector2(-1,0)]:
				res.append(coord+offset)
		return res

	func add_castle():
		var origin = Vector2( randi()%(int(mapsize.x/2)-6)+3 , randi()%(int(mapsize.y)-9)+4 )

		for offset in [Vector2(0,0), Vector2(1,0),Vector2(1,1),Vector2(0,1)]: 
			var new = origin+offset
			generated[new.x][new.y] = "Cr"
		for offset in get_castle_adj(origin):
			setfloor(offset, 1)
		
		var blueorigin = flip_coord(origin)-Vector2(1,1)
		for offset in [Vector2(0,0), Vector2(1,0),Vector2(1,1),Vector2(0,1)]: 
			var new = blueorigin+offset
			generated[new.x][new.y] = "Cb"
		for offset in get_castle_adj(blueorigin):
			setfloor(offset, 1)
		
		#print("red, ",origin," blue, ",blueorigin)

	func get_middle():
		var rows = int(mapsize.y)
		var cols = int(mapsize	.x)
		var mid_row = rows / 2
		var mid_col = cols / 2
		var ul_row = mid_row - 1 if rows % 2 == 0 else mid_row
		var ul_col = mid_col - 1 if cols % 2 == 0 else mid_col
		return Vector2(ul_row, ul_col)
	func add_city():
		var origin = get_middle()
		for offset in [Vector2(0,0), Vector2(1,0),Vector2(1,1),Vector2(0,1)]: 
			var new = origin+offset
			setcoord(new,"Ct")
		for offset in get_castle_adj(origin):
			setfloor(offset,1)
		for offset in [Vector2(0,-2), Vector2(1,-2), Vector2(2,0),Vector2(2,1), \
			Vector2(0,2),Vector2(1,2), Vector2(-2,0),Vector2(-2,1)]:
			offset = origin+offset
			setfloor(offset,1)
	
	var adj8:= [Vector2(1,0),Vector2(0,1),Vector2(-1,0),Vector2(0,-1),\
			Vector2(1,1),Vector2(1,-1),Vector2(-1,-1),Vector2(-1,1)]
	var adj12 := [Vector2(1,0),Vector2(0,1),Vector2(-1,0),Vector2(0,-1),\
			Vector2(1,1),Vector2(1,-1),Vector2(-1,-1),Vector2(-1,1),\
			Vector2(2,0),Vector2(0,2),Vector2(-2,0),Vector2(0,-2)]
	
	func get_tiles(coord:Vector2, list:Array):
		var res = []
		for offset in list:
			var new = coord+offset
			if in_bounds(new):			res.append(generated[new.x][new.y])
		return res

	func set_tiles(coord:Vector2, list:Array, type:String, prob:float):
		for offset in list:
			var new = coord+offset
			if in_bounds(new): if randf()<prob:setcoord(new, type)

	func count(arr:Array): 
		var d := {"W":arr.count("W"),"G":arr.count("G"),"F":arr.count("F")}; 
		for k in d: d[k]=float(d[k])
		return d

	func to_file(s:=""):
		var mx = mapsize.x; var my = mapsize.y
		
		var file = File.new()
		s = s if s != "" else seedstr
		file.open("res://map"+s+".txt", File.WRITE)

		var map = []
		for y in range(my):
			var res = []
			for x in range(mx):
				res.append(generated[x][y])
			var mapline = PoolStringArray(res).join(",")
			map.append(mapline)
		file.store_string(PoolStringArray(map).join("\n"))
		file.close()


	var coordflipmap := {"W":"W","F":"F","Cr":"Cb","Cb":"Cr","Ct":"Ct","G":"G","R":"B","B":"R"}
	func make_symmetric():
		for y in range(mapsize.y):
			for x in range(mapsize.x):
				var flipped = flip_coord(Vector2(x,y))
				generated[flipped.x][flipped.y] = coordflipmap[generated[x][y]]
	
	func flip_coord(coord:Vector2):
		return (mapsize - Vector2(1,1))-coord

	
	func add_goldmines():
		for y in range(mapsize.y):
			for x in range(mapsize.x):
				var coord = Vector2(x,y)
				var list:Array = get_tiles(coord,adj12)
				if count(list)["W"]/len(list) >= 0.8:
					setgold(coord, .75)
					if get_tile(coord) == "G":
						set_tiles(coord, adj12, "F", 0.95)



	#prob from percentage, inspired by sigmoid function
	func get_prob(percentage:float):
		var i=.8;var j=1; var k=12; var l=5; var m=0.05
		return (i/ (j+exp(-(k*percentage - l)))) + m

	func sum(arr): 
		var s=0.0; 
		for x in arr: s+=x; return s

	func flip_tile(coord:Vector2):
		var flipmap = {"W":"F","F":"W"}
		var neighbors = get_tiles(coord, adj12)
		var type = get_tile(coord)
		var counts = count(neighbors)
		var flipcount:float = counts[type]
		
		var percentage = flipcount/sum(counts.values())
		
		var prob = get_prob(percentage); 
		if type =="F":
			if percentage<0.85: prob = 0
			else: prob *= 0.5

		if randf() < prob:
			#print(type, " ",prob, " ", flipmap[type])
			setcoord(coord, flipmap[type])

	func transform_map():
		for y in range(mapsize.y):
			for x in range(mapsize.x):
				var coord = Vector2(x,y)
				if is_edge(coord):
					if get_tile(coord)=="F" and count(get_tiles(coord,adj12)).get("G")==0 : setwall(coord, 0.5)  
					#more walls near edge
				elif get_tile(coord) in ["F","W"]: #only process floors and walls
					flip_tile(coord)
					
	func bishop_pathways():
		var directions = [Vector2(1,1), Vector2(1,-1)]
		for n in range(randi()%3+6):
			var x = randi()%int(mapsize.x); var y = randi()%int(mapsize.y)
			for k in range(-2,3):
				setfloor(Vector2(x,y), 0.5)

	func add_piece():
		var num = 2 if randf()<0.9 else 3
		for n in num:
			while true:
				var x = randi()%int(mapsize.x); var y = 0
				if mapsize.x-1-x>0: y=randi()%int(mapsize.x-1-x)
				
				var coord=Vector2(x,y)
				if get_tile(coord)=="F":
					setcoord(coord, "R")
					print("piece added at ",coord)
					break
		make_symmetric()

class Prim:
	var cells := []
	var walls := []
	var generated := []
	var adj = [Vector2(2,1),Vector2(2,-1), Vector2(-2,-1),Vector2(-2,1), Vector2(2,-1),\
		Vector2(1,-2),Vector2(1,2), Vector2(-1,-2),Vector2(-1,2),
		Vector2(1,0),Vector2(0,1),Vector2(-1,0),Vector2(0,-1),\
		Vector2(1,1),Vector2(1,-1),Vector2(-1,-1),Vector2(-1,1)]
		
	var mapsize:Vector2
	
	func get_prob(x:float):
		var h=0.95; var i=10; var j=0.2; var k=0.9; var l=-0.08
		return (h/ (i*x*x*x+j*x+k)) + l 
	
	func in_bounds(coord:Vector2)->bool:
		return coord.x>=0 and coord.y>=0 && coord.x < mapsize.x and coord.y< mapsize.y
	
	func get_adj(coord:Vector2):
		var res = []
		for offset in adj:
			var new = coord+offset
			if in_bounds(new):	res.append(new)
		return res

	func count(list:Array):
		return list.count(-1)

	func setfloor(coord:Vector2, prob:float): if randf()<prob: generated[coord.x][coord.y] = -1
	func setwall(coord:Vector2, prob:float): if randf()<prob: generated[coord.x][coord.y] = 1
	
	func generate(seedstr:String, size:Vector2, floorprob:float)->Array:
		seed(seedstr.hash())
		
		generated.resize(size.x)
		for x in range(size.x):
			generated[x] = []; generated[x].resize(size.y)
		for x in range(size.x):for y in range(size.y): setwall(Vector2(x,y),1)
		
		mapsize= size

		var x = randi()%int(size.x); var y = randi()%int(size.y); var c=Vector2(x,y)
		setfloor(c,1)
		var visited = [c]
		walls = get_adj(c)
		
		var i = 0
		while len(walls) > 0:
			var w:Vector2 = walls.pop_at(randi()%len(walls)) #random wall
			visited.append(w)
			
			var neighbors = get_adj(w)
			var percentage = count(neighbors)/len(neighbors)
			
			if randf()<get_prob(percentage):
				if w.x==0 or w.y==0:
					setfloor(w, 0.2) #less floors near edge
				else:
					setfloor(w, floorprob)
				cells.append(w)

				for n in (neighbors):
					if not (n in walls or n in visited): walls.append(n)
					

		return generated
