extends CharacterBody2D

#additional steps
#add a MultiplayerSynchronizer to the scene
#It is to help sync between clients and server
#click add property to sync button at bottom left
#select the basic_player node and for the property select
#under node select position


#when player enter scene tree
func _enter_tree():
	#we set the multiplayer authority to name/ID
	set_multiplayer_authority(name.to_int())


func _physics_process(delta):
	#user can only control this node if it have multiplayer authority
	if is_multiplayer_authority():
		velocity = Input.get_vector("ui_left","ui_right","ui_up","ui_down") * 400
	move_and_slide()

