extends Node

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
	if Input.is_action_just_pressed("scene_reload"):
		get_tree().reload_current_scene()