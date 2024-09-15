extends Control


@onready var messaging_line_edit = $MessagingLineEdit

@onready var message_box_text_edit = $MessageBoxTextEdit

@onready var world_name_label = $Panel/VBoxTitle/WorldNameLabel

@onready var v_box_display_player = $PlayerInfoScroll/VBoxDisplayPlayer

var player_label_scene = preload("res://Scenes/player_info_label.tscn")



@onready var start_game_button = $StartGameButton

var game_directory = "res://Scenes/world.tscn"


# Called when the node enters the scene tree for the first time.
func _ready():
	start_game_button.disabled = false
	multiplayer.peer_connected.connect(when_peer_connected)
	multiplayer.peer_disconnected.connect(when_peer_disconnected)
	multiplayer.connected_to_server.connect(when_connected_to_server)
	multiplayer.connection_failed.connect(when_connection_failed)
	multiplayer.server_disconnected.connect(when_server_disconnected)
	#PlayerDisconnected
	Lobby.PlayerDisconnectedMSG.connect(show_player_disconnect_msg)
	#Lobby.PlayerConnectedMSG.connect(show_player_connected_msg)
	Lobby.PlayerDisconnectedRMList.connect(remove_player_and_update_list)
	
	#send message through RPC to all other players
	#player connected message will be shown at other other player screen
	send_message_to_id()
	
	#load world name base on Host's world name info
	_load_world_name()
	
	var peer = multiplayer.get_peers()
	print(peer)
	#check if peer empty, meaning if client join yet or not
	if peer.is_empty():
		print("empty, send to server only")
		_pass_playerlist_to_client()
	else:
		print("have peer, send to all")
		_pass_playerlist_to_client.rpc()
	
	#if multiplayer.is_server():
		#start_game_button.disabled = false
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(Lobby.player_list)
	pass
	
	
#func not in use
func sort_ascending(a, b):
	if a[0] < b[0]:
		return true
	return false

#func not in use
func sorting():
	pass
	#var my_items = [[5, "Potato"], [9, "Rice"], [4, "Tomato"]]
	#my_items.sort_custom(sort_ascending)
	#print(my_items) # Prints [[4, Tomato], [5, Potato], [9, Rice]].

#queue free all the children in the v_box
func _delete_player_list():
	for n in v_box_display_player.get_children():
		v_box_display_player.remove_child(n)
		n.queue_free()

func _load_player_list():
	print("Loading Player List...")
	var player_list_array = []
	var player_list = Lobby.player_list
	for item in player_list:
		var player_detail_array = []
		#append the ID and name
		#player_detail_array.append(player_list[item].order)
		player_detail_array.append(item)
		player_detail_array.append(player_list[item].name)
		#print(player_detail_array)
		player_list_array.append(player_detail_array)
	print("Player list array")
	print(player_list_array)
	#player_list_array.sort_custom(sort_ascending)
	#print("sort results...")
	#print(player_list_array)
	print("Instanciating...")
	for i in player_list_array:
		#instanciating preload player_label_scene
		var player_label_instance = player_label_scene.instantiate()
		#add player_label_scene to v_box
		v_box_display_player.add_child(player_label_instance)
		#get player_name_label
		var name_label = player_label_instance.get_node("GridContainer/PlayerNameLabel")
		#print("I is:")
		#print(i)
		#get the name field is index 1 which is the 2nd item of the array
		var name = i[1]
		#set player_name_label
		name_label.text = "  "+name



@rpc("any_peer","call_local","reliable")
func show_player_connected_msg(connected_name):
	print("Showing player connected msg...")
	print(connected_name)
	message_box_text_edit.text += str(connected_name, " has joined", "\n")
	#make message auto scroll
	#get line count and set scroll_vertical to line_count value
	var line_count = message_box_text_edit.get_line_count()
	message_box_text_edit.scroll_vertical = line_count
	


@rpc("any_peer","call_local","reliable")
func show_player_disconnect_msg(disconnected_name):
	print("Showing player disconnect msg...")
	print(disconnected_name)
	message_box_text_edit.text += str(disconnected_name, " has disconnected", "\n")
	#make message auto scroll
	#get line count and set scroll_vertical to line_count value
	var line_count = message_box_text_edit.get_line_count()
	message_box_text_edit.scroll_vertical = line_count
	

func when_peer_connected():
	print("GLM:when_peer_connected")

func when_peer_disconnected():
	print("GLM:when_peer_disconnected")

func when_connected_to_server():
	print("GLM:when_connected_to_server")

func when_connection_failed():
	print("GLM:when_connection_failed")

func when_server_disconnected():
	print("GLM:when_server_disconnected")
	get_tree().change_scene_to_file("res://Scenes/disconnect_screen.tscn")
	

func _load_world_name():
	print("Load world name...")
	print(Lobby.players[1].world_name)
	world_name_label.text = Lobby.players[1].world_name

func _on_leave_pressed():
	Lobby.remove_multiplayer_peer()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_print_logs_players_pressed():
	print("Lobby Players:")
	print(Lobby.players)
	
	#print("Lobby Player Info:")
	#print(Lobby.player_info)
	#print("=======================")
	#print(Lobby.players[1].name)
	#print(Lobby.players[1].name)


func _on_print_logs_2_pressed():
	print("Log 2 Print player list")
	print(Lobby.player_list)


func _on_print_logs_3_pressed():
	print("log 3")
	
	Lobby._spawn_player()


func send_message_to_id():
	print("send msg to ID")
	var peer_id = multiplayer.get_peers()
	#print(peer_id)
	var my_id = multiplayer.get_unique_id()
	#print(my_id)
	var my_name = Lobby.players[my_id].name
	for i in peer_id:
		show_player_connected_msg.rpc_id(i,my_name)


@rpc("any_peer","call_local","reliable")
func msg_rpc(player_name, message):
	print("message")
	message_box_text_edit.text += str("[",player_name,"]", ":" , message, "\n")
	#make message auto scroll
	#get line count and set scroll_vertical to line_count value
	var line_count = message_box_text_edit.get_line_count()
	message_box_text_edit.scroll_vertical = line_count


func _on_messaging_line_edit_text_submitted(new_text):
	if new_text.is_empty():
		print("text empty")
		return
	print("text sent")
	print(new_text)
	print("Multiplayer.ID is:")
	print(multiplayer.get_unique_id())
	print("Player name is:")
	print(Lobby.players[multiplayer.get_unique_id()].name)
	var player_name = Lobby.players[multiplayer.get_unique_id()].name
	rpc("msg_rpc",player_name, messaging_line_edit.text)
	messaging_line_edit.text = ""

@rpc("any_peer","call_local","reliable")
func pass_playerlist_rpc(playerlist):
	if multiplayer.is_server():
		return
	else:
		print("Received player list from server")
		print(playerlist)
		Lobby.player_list = playerlist
		_delete_player_list()
		_load_player_list()

#@rpc("authority","call_local","reliable")
@rpc("any_peer", "reliable")
func _pass_playerlist_to_client():
	if multiplayer.is_server():
		print("is server, Passing playerlist to client:")
		Lobby.player_list =  Lobby.players
		#print(Lobby.player_list)
		#var peer_id = multiplayer.get_peers()
		#for i in peer_id:
			#pass_playerlist_rpc.rpc_id(i, Lobby.player_list)
		rpc("pass_playerlist_rpc",Lobby.player_list)
		print("Updating server's playerlist")
		_delete_player_list()
		_load_player_list()

	else:
		print("Not server")


func remove_player_and_update_list():
	print("removing player and updating list...")
	var peer = multiplayer.get_peers()
	print(peer)
	if peer.is_empty():
		print("empty, send to server only")
		_pass_playerlist_to_client()
	else:
		print("have peer, send to all")
		_pass_playerlist_to_client.rpc()


func _on_start_game_button_pressed():
	#Lobby.load_game.rpc(game_directory)
	#if not multiplayer.is_server():
		#return
	#Lobby.disconnect_signal()
	#multiplayer.peer_connected.disconnect(add_player)
	#multiplayer.peer_disconnected.disconnect(del_player)
	#await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://Scenes/world.tscn")
	#if multiplayer.is_server():
		#change_level.call_deferred(load("res://Scenes/world.tscn"))
	

#func change_level(scene: PackedScene):
	#var level = $Level
	#for c in level.get_children():
		#level.remove_child(c)
		#c.queue_free()
	## Add new level.
	#level.add_child(scene.instantiate())

