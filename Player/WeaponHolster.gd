extends Spatial

var current_weapon_id = 0

enum {
	SMG = 0,
	RIFLE = 1,
	MAX_WEAPON_ID
}

var weapons

func _ready():
	weapons = {
		0: $SmgPosition,
		1: $RiflePosition
	}

func _process(delta):
	var weapon_changed = false
	var temp_weapon_id = current_weapon_id
	
	if Input.is_action_just_released("weapon_previous"):
		if temp_weapon_id == 0:
			temp_weapon_id = (MAX_WEAPON_ID - 1)
		else:
			temp_weapon_id -= 1
		weapon_changed = true
	elif Input.is_action_just_released("weapon_next"):
		if temp_weapon_id == (MAX_WEAPON_ID - 1):
			temp_weapon_id = 0
		else:
			temp_weapon_id += 1
		weapon_changed = true
	else:
		weapon_changed = false
	
	if weapon_changed:
		_on_ActionRaycast_weapon_equipped(temp_weapon_id)
		
	if Input.is_action_pressed("weapon_fire"):
		fire_weapon(delta)
	if Input.is_action_just_released("weapon_fire"):
		stop_firing_weapon()
	if Input.is_action_just_pressed("weapon_reload"):
		reload_weapon()

func _on_ActionRaycast_weapon_equipped(id):
	var old_weapon = weapons[current_weapon_id].get_child(0)
	var new_weapon = weapons[id].get_child(0)
	
	if old_weapon != null:
		old_weapon.hide()
	
	if new_weapon != null:
		new_weapon.show()
	
	current_weapon_id = id

func fire_weapon(delta):
	var current_weapon = weapons[current_weapon_id].get_child(0)
	
	if current_weapon != null:
		current_weapon.fire(delta)

func stop_firing_weapon():
	var current_weapon = weapons[current_weapon_id].get_child(0)
	
	if current_weapon != null:
		current_weapon.stop_fire()

func reload_weapon():
	var current_weapon = weapons[current_weapon_id].get_child(0)
	
	if current_weapon != null:
		current_weapon.reload()