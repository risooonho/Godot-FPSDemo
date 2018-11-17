extends CanvasLayer

var current_ammo
var total_ammo

func _ready():
	current_ammo = $MarginContainer/VBoxContainer/InformationContainer/WeaponInformation/AmmoChamberValueLabel
	total_ammo = $MarginContainer/VBoxContainer/InformationContainer/WeaponInformation/AmmoTotalShotsLabel

#sender is the WeaponHolster itself
func _on_WeaponHolster_weapon_fired(sender):
	get_weapon_stats(sender)

func _on_WeaponHolster_weapon_changed(sender):
	get_weapon_stats(sender)

func get_weapon_stats(weapon_holster):
	var weapon = weapon_holster.get_equipped_weapon()
	
	if weapon != null:
		current_ammo.text = str(weapon.current_chamber_capacity)
		total_ammo.text = str(weapon.chamber_capacity * weapon.current_magazine_number)
	else:
		current_ammo.text = "0"
		total_ammo.text = "0"

func _on_WeaponHolster_weapon_reloaded(sender):
	get_weapon_stats(sender)
