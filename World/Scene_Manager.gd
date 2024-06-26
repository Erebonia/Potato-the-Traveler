extends Node
class_name Scene_Manager

var last_scene_name: String 
var current_scene: String
var scene_dir_path = "res://Scenes/"
	
func change_scene(from, to_scene_name: String) -> void:
	last_scene_name = from.name
		
	# Fade effect
	TransitionScene.transition() 
	AudioManager.get_node("Footsteps_Grass").stop()
	AudioManager.get_node("Footsteps_Stone").stop()
	AudioManager.get_node("Scene_Transition").play()
	
	#Change Scene
	var full_path = scene_dir_path + to_scene_name + ".tscn"
	from.get_tree().call_deferred("change_scene_to_file", full_path)
