extends RayCast

var weapon_holster

enum {
	SMG = 0,
	RIFLE = 1,
}

signal weapon_equipped(id)

func _ready():
	 weapon_holster = get_node("../WeaponHolster")

func _process(delta):
	if Input.is_action_just_pressed("action_activate"):
		if is_colliding():
			var collider = get_collider()

			if collider.name == "WeaponArea":
				equipWeapon(collider.get_parent())

func equipWeapon(weapon_spatial):
	var weapon_parent = weapon_spatial.get_parent()
	
	if weapon_spatial.weapon_id == SMG:
		# Reparent the weapon to us
		var weapon_position = weapon_holster.get_node("SmgPosition")
		weapon_parent.remove_child(weapon_spatial)
		weapon_position.add_child(weapon_spatial)

		# Needed to have the weapon in the good position
		weapon_spatial.global_transform = weapon_position.global_transform
	elif weapon_spatial.weapon_id == RIFLE:
		var weapon_position = weapon_holster.get_node("RiflePosition")
		weapon_parent.remove_child(weapon_spatial)
		weapon_position.add_child(weapon_spatial)

		# Needed to have the weapon in the good position
		weapon_spatial.global_transform = weapon_position.global_transform
		
	emit_signal("weapon_equipped", weapon_spatial.weapon_id)