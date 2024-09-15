extends Node

# Autoload named Lobby

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal JoinGameError
signal CreateGameError
signal ServerHostSuccessfully
signal PlayerDisconnectedMSG(disconnected_name)
signal LoadGameLobbyForClient
signal PlayerDisconnectedRMList


const DEFAULT_PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20
#var CURRENT_PORT = 0

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {"name": "Name"}
var world_name = ""
var player_list = {}
var player_inst_list = {}
var player_inst_array = []

var players_loaded = 0


var player_character = preload("res://Scenes/player_character.tscn")
var test_character = preload("res://Scenes/basic_player.tscn")



func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok) #1
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func reset_var():
	players = {}
	world_name = ""
	player_list = {}
	players_loaded = 0

func join_game(ip_address, port_number, player_name):
	print("======= Joining Game =======")
	if ip_address.is_empty():
		print("IP empty, using default IP")
		ip_address = DEFAULT_SERVER_IP
		print(ip_address)
	if port_number.is_empty():
		print("Port Number empty, using Default Port")
		#CURRENT_PORT = DEFAULT_PORT
		port_number = DEFAULT_PORT
		print(port_number)
	else:
		print("Port Number have something, convert to int")
		port_number = int(port_number)
		print(port_number)
	
	var peer = ENetMultiplayerPeer.new()
	
	print("Ip Address is:")
	print(ip_address)
	var resolve = IP.resolve_hostname(ip_address,IP.TYPE_ANY)
	print("Hostname resolve:")
	print(resolve)
	print("Port Number is:")
	print(port_number)
	var error = peer.create_client(resolve, port_number)
	#peer.get_peer(1).set_timeout(0,0,3000)
	print("=== Connection Status ===")
	print(peer.get_connection_status())
	#peer.get_peer(1).set_timeout(0,0,7400)
	
	if error:
		print("if error, print connection status:")
		print(peer.get_connection_status())
		#I think won't have error unless, address/port is null
		JoinGameError.emit()
		return error
	print(peer.get_connection_status())
	peer.get_peer(1).set_timeout(0,0,7400)
	print(peer.get_connection_status())
	
	multiplayer.multiplayer_peer = peer
	print(peer.get_connection_status())
	player_info = {"name": player_name}
	
	


func create_game(user_world_name, player_name, port_number):
	print("======= Creating Game =======")
	if port_number.is_empty():
		print("Port Number empty, using Default Port")
		#CURRENT_PORT = DEFAULT_PORT
		port_number = DEFAULT_PORT
		print(port_number)
	else:
		print("Port Number have something, convert to int")
		port_number = int(port_number)
		print(port_number)
	var peer = ENetMultiplayerPeer.new()
	print("=== Connection Status ===")
	print(peer.get_connection_status())
	print("Port Number is:")
	print(port_number)
	var error = peer.create_server(port_number, MAX_CONNECTIONS)
	print(peer.get_connection_status())
	#It will error if same port number is used to create 2 game
	if error:
		print("if error, print connection status:")
		print(peer.get_connection_status())
		CreateGameError.emit()
		return error
	
	print(peer.get_connection_status())
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(_add_player_inst_to_list)
	
	_add_player_inst_to_list()
	#var player_inst = _instanciating_player()
	#print("++++ The player inst is +++++")
	#print(player_inst)
	
	player_info = {"name": player_name, "world_name": user_world_name}
	world_name = user_world_name
	players[1] = player_info
	player_connected.emit(1, player_info)
	
	print(peer.get_connection_status())
	
	#world_name = user_world_name
	print("emiting global: player_connected from create game")
	ServerHostSuccessfully.emit()
	

func _add_player_inst_to_list(id = 1):
	if multiplayer.is_server():
	
		print("intanciating player...")
		#var player_character_inst = player_character.instantiate()
		var player_character_inst = test_character.instantiate()
		
		print("My id is")
		print(id)
		player_character_inst.name = str(id)
		#var player_inst_info = {"player_inst" : player_character_inst}
		#player_inst_list[id] = player_inst_info
		#print("Player_inst_list:")
		#print(player_inst_list)
		
		player_inst_array.append(player_character_inst)
		print(player_inst_array)
		
		
		
		#player_character_inst.position = spawn_position.position
		#var player_name = player_character_inst.get_node("NameLabel")
		#player_name.text = str(my_id)
		
		#players.call_deferred("add_child",player_character_inst)

func _spawn_player():
	for i in player_inst_array:
		call_deferred("add_child",i)
	
	
	#for i in player_inst_list:
		#print(i)
		#print(player_inst_list[i])
		#print(player_inst_list[i].player_inst)
		#var player_inst = player_inst_list[1].player_inst
		#call_deferred("add_child",player_inst)


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null


# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)


# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		print("Number of players loaded")
		if players_loaded == players.size():
			$/root/Game.start_game()
			players_loaded = 0



# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	print("_on_player_connected")
	print("id:")
	print(id)
	print("player_info:")
	print(player_info)
	_register_player.rpc_id(id, player_info)
	
	

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	print("registering new player... :")
	#print("new player info")
	#print(new_player_info)
	var new_player_id = multiplayer.get_remote_sender_id()
	#print("New Player ID:")
	#print(new_player_id)

	players[new_player_id] = new_player_info
	
	print("Players:")
	print(players)
	player_connected.emit(new_player_id, new_player_info)
	print("emiting global: player_connected - from _register_player")
	
	var new_player_name = new_player_info.name
	#PlayerConnectedMSG.emit(new_player_name)
	
	LoadGameLobbyForClient.emit()
	


func _on_player_disconnected(id):
	print("_on_player_disconnected")
	#show player on message disconnected
	var disconnected_name = players[id].name
	PlayerDisconnectedMSG.emit(disconnected_name)
	
	players.erase(id)
	player_disconnected.emit(id)
	PlayerDisconnectedRMList.emit()
	print("emiting global: player_disconnected from _on_player_disconnected")


func _on_connected_ok():
	print("_on_connected_ok")
	var peer_id = multiplayer.get_unique_id()
	print("peer ID:")
	print(peer_id)
	players[peer_id] = player_info
	print("Players:")
	print(players)
	player_connected.emit(peer_id, player_info)
	print("emiting global: player_connected from _on_connected_ok")
	


func _on_connected_fail():
	print("_on_connected_fail")
	multiplayer.multiplayer_peer = null


func _on_server_disconnected():
	print("_on_server_disconnected")
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
	print("emiting global: server_disconnected from _on_server_disconnected")

#func disconnect_signal():
	#multiplayer.peer_connected.disconnect(_on_player_connected)
	#multiplayer.peer_disconnected.disconnect(_on_player_disconnected)
	#print("signal disconnected")
