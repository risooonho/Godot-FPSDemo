extends Spatial

enum FIRE_MODE { 
	SINGLE = 0,
	TRIPLE,
	FULL
}

export (int) var weapon_id = 1
export (float) var fire_rate_full = 1
export (float) var fire_rate_triple = 1
export (float) var fire_rate_single = 1
export (int) var fire_range = 0
export (int) var fire_mode = 0

export (int) var chamber_capacity = 10

var current_chamber_capacity = 10
var current_magazine_number = 5

var last_fire_time = 0
var can_fire = true
var has_fire = false
var fire_count = 0

func fire(delta):
	if current_chamber_capacity == 0:
		return
	
	if can_fire && !has_fire:
		$FireSound.play()
		current_chamber_capacity -= 1
		has_fire = true
		last_fire_time = 0
	elif can_fire && fire_mode == TRIPLE:
		if (last_fire_time >= fire_rate_triple):
			$FireSound.play()
			current_chamber_capacity -= 1
			last_fire_time = 0
			fire_count += 1
			
			if fire_count == 3:
				can_fire = false
		else:
			last_fire_time += delta * 10
	elif can_fire && fire_mode == FULL:
		if (last_fire_time >= fire_rate_full):
			$FireSound.play()
			current_chamber_capacity -= 1
			last_fire_time = 0
		else:
			last_fire_time += delta * 10

func stop_fire():
	can_fire = true
	fire_count = 0
	has_fire = false

func reload():
	if current_magazine_number == 0:
		return
	
	current_chamber_capacity = chamber_capacity
	current_magazine_number -= 1

func dump_weapon_stat():
	print("Chamber: " + str(current_chamber_capacity))
	print("Magazine: " + str(current_magazine_number))
	print("Total available: " + str(current_magazine_number * chamber_capacity))