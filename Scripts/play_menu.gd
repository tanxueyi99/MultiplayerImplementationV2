extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_create_game_pressed():
	get_tree().change_scene_to_file("res://Scenes/create_game_menu.tscn")


func _on_join_lan_game_pressed():
	get_tree().change_scene_to_file("res://Scenes/join_lan_game_menu.tscn")


func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
