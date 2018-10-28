extends "res://Scripts/Base.gd"

var is_mouse_visible = false

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if !is_mouse_visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			is_mouse_visible = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			is_mouse_visible = false
	
	if Input.is_action_just_pressed("scene_reload"):
		get_tree().reload_current_scene()