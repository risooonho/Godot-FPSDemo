###################################################################################
## FPS Controller Script                                                         ##
##                                                                               ##
## Description:                                                                  ##
## This script helps controlling the Player's head position to simulate the      ##
## crouch, crawl and standing positions change. It does so by responding to      ##
## signals emitted by the FPSController.gd script
##                                                                               ##
## Author: Jonathan Racaud                                                       ##
###################################################################################
extends Spatial

# Camera variables
export (Vector3) var crouch_position
export (Vector3) var crawl_position

var base_position

func _ready():
	base_position = translation

func _on_Player_start_crawling():
	translation = crawl_position

func _on_Player_start_crouching():
	translation = crouch_position

func _on_Player_start_flying():
	translation = base_position

func _on_Player_start_standing():
	translation = base_position

func _on_Player_start_walking():
	translation = base_position
