tool
extends EditorScript

var img

func _run():
	var res = generate(Vector2(30,30),"testing2")
	save_file(res)
	print(get_middle(mapsize))

func generate(size:Vector2, seedstr:String):
	seed(seedstr.hash())

	var noise = OpenSimplexNoise.new()
	noise.seed = seedstr.hash()
	
	noise.octaves = 3
	noise.period = 5

	mapsize = size
	mapseed = seedstr
	
	var generated = []

	generated.resize(size.x)
	for x in range(size.x):
		generated[x] = []
		generated[x].resize(size.y)

	for x in range(size.x):
		for y in range(size.y):
			generated[x][y] = noise.get_noise_2d(x,y)
			
	return generated

var mapsize :Vector2
var threshold = 0
var mapseed:String

func save_file(generated:Array):
	var mx = mapsize.x; var my = mapsize.y
	
	var file = File.new()
	file.open("res://map"+mapseed+".txt", File.WRITE)

	for y in range(my):
		var mapline:= ""
		for x in range(mx):
			var res = "F" if generated[x][y]<threshold else "W"
			mapline += res+","
		file.store_line(mapline)
	file.close()

func get_middle(size):
	var rows = int(size.y)
	var cols = int(size.x)
	var mid_row = rows / 2
	var mid_col = cols / 2
	var ul_row = mid_row - 1 if rows % 2 == 0 else mid_row
	var ul_col = mid_col - 1 if cols % 2 == 0 else mid_col
	return Vector2(ul_row, ul_col)

#TODO: reflect castles 
func make_symmetric(generated:Array):
	for y in range(mapsize.y):
		for x in range(mapsize.x):
			var flipped = flip_coord(Vector2(x,y))
			generated[flipped.x][flipped.y] = generated[x][y]

func flip_coord(coord:Vector2):
	return (mapsize - Vector2(1,1))-coord

