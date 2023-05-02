extends Node


# Signals to let lobby GUI know what's going on.
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

# Default game server port. Can be any number between 1024 and 49151.
# Not on the list of registered or common ports as of November 2020:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 10567

# Max number of players.
const MAX_PEERS = 2

var peer = null

# Name for my player.
var player_name = "Sir Knight"

# Names for remote players in id:name format.
var players = {}
var players_ready = []


func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


# Callback from SceneTree.
func _player_connected(id):
	# Registration of a client beings here, tell the connected player that we are here.
	rpc_id(id, "register_player", player_name)


# Callback from SceneTree.
func _player_disconnected(id):
	if has_node("/root/Map"): # Game is in progress.
		if get_tree().is_network_server():
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
	else: # Game is not in progress.
		# Unregister this player.
		unregister_player(id)


# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	# We just connected to a server
	emit_signal("connection_succeeded")


# Callback from SceneTree, only for clients (not server).
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()


# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")


# Lobby management functions.

remote func register_player(new_player_name):
	var id = get_tree().get_rpc_sender_id()
	players[id] = new_player_name
	emit_signal("player_list_changed")


func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")


remote func pre_start_game(mapseed,method,floorprob):
	# Change scene.
	var mapscene = load("res://Map.tscn").instance()
	get_tree().get_root().add_child(mapscene)

	var path = "res://map"+mapseed+".txt"

	var f := File.new()
	if not f.file_exists(path):
		var generate = load("res://random/generate.gd")
		var map = generate.Map.new(mapseed, Vector2(30,30), 0.5)
		var generator = generate.Simplex.new() if method=="Noise" else generate.Prim.new()
	
		map.generate(generator)

		map.add_goldmines()	
		map.transform_map()
		map.bishop_pathways()
		map.make_symmetric()
		map.add_castle()
		map.add_city()
		map.add_piece()
		
		map.to_file()

	global.get_map().load_map(path)
	#DEBUG
	#global.get_map().demo()

	get_tree().get_root().get_node("Lobby").hide()
	
	global.get_map().get_node("PlayerRed").set_network_master(1) #set unique id as master.
	global.get_map().get_node("PlayerBlue").set_network_master(2) #set unique id as master.


	if not get_tree().is_network_server():
		# Tell server we are ready to start.
		global.get_map().active_player = global.get_map().get_node("PlayerBlue")
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())	
	else:
		global.get_map().active_player = global.get_map().get_node("PlayerRed")		
		if players.size() == 0:
			post_start_game()


remote func post_start_game():
	get_tree().set_pause(false) # Unpause and unleash the game!


remote func ready_to_start(id):
	assert(get_tree().is_network_server())

	if not id in players_ready:
		players_ready.append(id)

	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()


func host_game(new_player_name):
	player_name = new_player_name
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PEERS)
	peer.set_allow_object_decoding(true)
	get_tree().set_network_peer(peer)

func join_game(ip, new_player_name):
	player_name = new_player_name
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, DEFAULT_PORT)
	peer.set_allow_object_decoding(true)
	get_tree().set_network_peer(peer)


func get_player_list():
	return players.values()


func get_player_name():
	return player_name


func begin_game(mapseed, method, floorprob):
	assert(get_tree().is_network_server())

	for p in players:
		rpc_id(p, "pre_start_game", mapseed, method, floorprob)

	pre_start_game(mapseed, method, floorprob)


func end_game():
	if has_node("/root/Map"): # Game is in progress.
		# End it
		get_node("/root/Map").queue_free()

	emit_signal("game_ended")
	players.clear()
