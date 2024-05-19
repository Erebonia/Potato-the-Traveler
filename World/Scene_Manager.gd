extends Node
class_name Scene_Manager

var player : Player
var last_scene_name: String 
var current_scene: String
var scene_dir_path = "res://Scenes/"
	
func change_scene(from, to_scene_name: String) -> void:
	last_scene_name = from.name
	print(from)

	player = from.player
	player.get_parent().remove_child(player)
		
	# Fade effect
	TransitionScene.transition() 
	AudioManager.get_node("Footsteps_Grass").stop()
	AudioManager.get_node("Footsteps_Stone").stop()
	AudioManager.get_node("Scene_Transition").play()
	
	#Change Scene
	var full_path = scene_dir_path + to_scene_name + ".tscn"
	var new_scene = load(full_path).instantiate()
	new_scene.add_child(player)  # Add the player to the new scene
	from.get_tree().call_deferred("change_scene_to_file", full_path)
