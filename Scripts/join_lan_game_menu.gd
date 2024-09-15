extends Control

@onready var ip_address = $Panel/MarginContainer/GridCreateGameInfo/GridGameInfo1/IPAddress
@onready var port_number = $Panel/MarginContainer/GridCreateGameInfo/GridGameInfo1/PortNumber
@onready var join = $Panel/MarginContainer/GridCreateGameInfo/GridButton/Join
@onready var error_message_label = $ErrorMessageLabel
@onready var back = $Panel/MarginContainer/GridCreateGameInfo/GridButton/Back
@onready var player_name = $Panel/MarginContainer/GridCreateGameInfo/GridGameInfo1/PlayerName
@onready var port_error_message_label = $PortErrorMessageLabel
@onready var name_error_message_label = $NameErrorMessageLabel


var default_error_message = ""
var error_message = "Error, please check your IP and Port"
var connect_fail_message = "Connecting To Server Failed\nPlease Check IP and Port"
var regex_port = true
var regex_port_error_message = "Invalid port number"
var regex_name = false
var regex_name_error_message = "Alphanumeric and _ - only\nNo start / end whitespace"
# Called when the node enters the scene tree for the first time.
func _ready():
	error_message_label.text = default_error_message
	multiplayer.connection_failed.connect(when_player_connect_fail)
	multiplayer.connected_to_server.connect(when_player_connected) #1
	Lobby.JoinGameError.connect(when_player_get_error)
	Lobby.LoadGameLobbyForClient.connect(load_game_lobby_for_client)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_game_lobby_for_client():
	print("Load game lobby for client...")
	#solve problem for message rpc, can be solve next time
	#await get_tree().create_timer(1).timeout
	#print("time up")
	get_tree().change_scene_to_file("res://Scenes/game_lobby_menu.tscn")

func when_player_connected():
	print("When player connected.")
	#add proper background loading if needed here
	#get_tree().change_scene_to_file("res://Scenes/game_lobby_menu.tscn")
	


func when_player_connect_fail():
	print("When player connect fail...")
	error_message_label.text = connect_fail_message
	change_default_state()


func when_player_get_error():
	print("When player get error...")
	error_message_label.text = error_message
	change_default_state()


func _on_join_pressed():
	error_message_label.text = default_error_message
	port_error_message_label.text = default_error_message
	name_error_message_label.text = default_error_message
	
	if regex_port == false && regex_name == false:
		print("both regex false")
		port_error_message_label.text = regex_port_error_message
		name_error_message_label.text = regex_name_error_message
	elif regex_name == true:
		print("name ok")
		if regex_port == true:
			print("port ok")
			change_loading_state()
			Lobby.join_game(ip_address.text,port_number.text,player_name.text)
		else:
			print("regex port false")
			port_error_message_label.text = regex_port_error_message
			
			
	else:
		print("regex name false")
		name_error_message_label.text = regex_name_error_message
	
	
	


func change_loading_state():
	back.disabled = true
	join.disabled = true
	player_name.editable = false
	ip_address.editable = false
	port_number.editable = false
	join.text = "  Loading...  "

func change_default_state():
	join.text = "  Join  "
	join.disabled = false
	back.disabled = false
	player_name.editable = true
	ip_address.editable = true
	port_number.editable = true

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/play_menu.tscn")


func _on_port_number_text_changed(new_text):
	print("port number text change")
	print(new_text)
	var regex = RegEx.new()
	#No leading 0 for port number and accept only number or empty string
	regex.compile("^([1-9]|^$)[0-9]*$")

	var result = regex.search(new_text)
	if result:
		print("true")
		regex_port = true
	else:
		print("false")
		regex_port = false
	#if new_text.is_empty():
		#print("true")
		#regex_port = true
	#elif result:
		#print("true")
		#regex_port = true
	#else:
		#print("false")
		#regex_port = false
		#
	
	

func _on_port_number_text_change_rejected(rejected_substring):
	print("Rejected string")
	print(rejected_substring)


func _on_player_name_text_changed(new_text):
	print("Player name text change")
	print(new_text)
	var regex = RegEx.new()
	#No empty string and alphanumeric only and can use _ - no white space at begining and end
	regex.compile("^[-a-zA-Z0-9'_-]+(\\s+[-a-zA-Z0-9'_-]+)*$")
	#regex.compile("^([0-9]|[1-9][0-9])$")
	var result = regex.search(new_text)
	if result:
		print("true")
		regex_name = true
	else:
		print("false")
		regex_name = false


func _on_player_name_text_change_rejected(rejected_substring):
	print("Rejected string")
	print(rejected_substring)
