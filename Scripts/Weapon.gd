extends Spatial

export (float) var fire_rate = 1
var shot = false
var shot_last

func fire():
	$FireSound.play()
