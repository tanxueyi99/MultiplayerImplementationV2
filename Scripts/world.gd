extends Node3D

#var player_character = preload("res://Scenes/player_character.tscn")

#@export var player_character: PackedScene

@onready var csg_floor = $Stage/CSGFloor

@onready var spawn_position = $Stage/CSGFloor/SpawnPosition

#@onready var players = $Players
@onready var players = $MultiplayerSpawner/Players

@onready var multiplayer_spawner = $MultiplayerSpawner

# Called when the node enters the scene tree for the first time.
func _ready():
	
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var my_id = multiplayer.get_unique_id()
	#_add_player(my_id)
	await get_tree().create_timer(1).timeout
	_add_player.rpc_id(1,my_id)
	

func add_player():
	print("Peer connected... add player...")

func del_player():
	print("peer dc... deleting player..")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

@rpc("any_peer","call_local","reliable")
func _add_player(my_id):
#func _add_player(id = 1):
	#if multiplayer.is_server():
	
	print("adding player...")
	var player_character_inst = preload("res://Scenes/player_character.tscn").instantiate()
	#var player_character_inst = player_character.instantiate()
	print(my_id)
	player_character_inst.name = str(my_id)
	player_character_inst.position = spawn_position.position
	var player_name = player_character_inst.get_node("NameLabel")
	player_name.text = str(my_id)
	#csg_floor.add_child(player_character_inst)
	players.call_deferred("add_child",player_character_inst)
	
