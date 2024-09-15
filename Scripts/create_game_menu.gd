extends Control

@onready var player_name = $Panel/MarginContainer/GridCreateGameInfo/GridGameInfo1/PlayerName
@onready var world_name = $Panel/MarginContainer/GridCreateGameInfo/GridGameInfo1/WorldName
@onready var port_number = $Panel/MarginContainer/GridCreateGameInfo/HBoxPortNumber/PortNumber

@onready var error_message_label = $ErrorMessageLabel
@onready var port_error_message_label = $PortErrorMessageLabel
@onready var name_error_message_label = $NameErrorMessageLabel

@onready var world_name_error_message_label = $WorldNameErrorMessageLabel

@onready var back = $Panel/MarginContainer/GridCreateGameInfo/GridButton/Back
@onready var create = $Panel/MarginContainer/GridCreateGameInfo/GridButton/Create


var regex_port = true
var regex_port_error_message = "Invalid port number"
var regex_name = false
var regex_name_error_message = "Alphanumeric and _ - only\nNo start / end whitespace"
var regex_world_name = false
var regex_world_name_error_message = "Alphanumeric and _ ' - only\nNo start / end whitespace"
var default_error_message = ""
var create_game_error_message = "Fail to create server\nplease check port number"


# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(when_peer_connected)
	multiplayer.peer_disconnected.connect(when_peer_disconnected)
	multiplayer.connected_to_server.connect(when_connected_to_server)
	multiplayer.connection_failed.connect(when_connection_failed)
	multiplayer.server_disconnected.connect(when_server_disconnected)
	Lobby.CreateGameError.connect(when_server_player_get_error)
	Lobby.ServerHostSuccessfully.connect(when_server_hosted_successfully)
	#Lobby.player_connected().connect(test)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func when_peer_connected():
	print("when_peer_connected")

func when_peer_disconnected():
	print("when_peer_disconnected")

func when_connected_to_server():
	print("when_connected_to_server")

func when_connection_failed():
	print("when_connection_failed")

func when_server_disconnected():
	print("when_server_disconnected")

func when_server_player_get_error():
	print("when_server_player_get_error")
	
	error_message_label.text = create_game_error_message
	change_default_state()

func when_server_hosted_successfully():
	print("Server hosted successfully")
	get_tree().change_scene_to_file("res://Scenes/game_lobby_menu.tscn")
	

func test():
	print("test")

func _on_create_pressed():
	error_message_label.text = default_error_message
	port_error_message_label.text = default_error_message
	name_error_message_label.text = default_error_message
	world_name_error_message_label.text = default_error_message
	
	
	if regex_name == true && regex_port == true && regex_world_name == true:
		print("Fields correct, creating game...")
		change_loading_state()
		
		Lobby.create_game(world_name.text, player_name.text, port_number.text)
	
	if regex_name == false:
		name_error_message_label.text = regex_name_error_message
	
	if regex_port == false:
		port_error_message_label.text = regex_port_error_message
	
	if regex_world_name == false:
		world_name_error_message_label.text = regex_world_name_error_message
	
	#Lobby.create_game(world_name.text, player_name.text, int(port_number.text))
	#get_tree().change_scene_to_file("res://Scenes/game_lobby_menu.tscn")
	

func change_loading_state():
	player_name.editable = false
	world_name.editable = false
	port_number.editable = false
	create.disabled = true
	back.disabled = true
	
func change_default_state():
	player_name.editable = true
	world_name.editable = true
	port_number.editable = true
	create.disabled = false
	back.disabled = false

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


func _on_world_name_text_changed(new_text):
	print("World name text change")
	print(new_text)
	var regex = RegEx.new()
	#No empty string and alphanumeric only and can use _ - no white space at begining and end
	regex.compile("^[-a-zA-Z0-9'_-]+(\\s+[-a-zA-Z0-9'_-]+)*$")
	#regex.compile("^([0-9]|[1-9][0-9])$")
	var result = regex.search(new_text)
	if result:
		print("true")
		regex_world_name = true
	else:
		print("false")
		regex_world_name = false
