###################################################################################
## FPS Controller Script                                                         ##
##                                                                               ##
## Description:                                                                  ##
## This script gives basic FPS movements                                         ##
## and is based on the video tutorial series                                     ##
## Godot - First Person Controller by Jeremy Bullock.                            ##
##                                                                               ##
## The script has been modified to allow modifying the                           ##
## different parameters directly from the Inspector which                        ##
## gives more flexibility on the final behavior in the                           ##
## game and also includes more movement features.                                ##
##                                                                               ##
## Author: Jonathan Racaud                                                       ##
## Original Author: Jeremy Bullock (https://github.com/turtletooth)              ##
## Youtube tutorial:                                                             ##
##		https://www.youtube.com/playlist?list=PLTZoMpB5Z4aD-rCpluXsQjkGYgUGUZNIV ##
###################################################################################
extends KinematicBody

# Camera variables.
export (float) var mouse_sensitivity = 0.3
export (int) var max_camera_angle = 90
export (int) var min_camera_angle = -90
var camera_angle = 0
var camera_change = Vector2()

# Movements variables.
var velocity = Vector3()
var direction = Vector3()

# Flying variables. Used if you want the player to fly
# or use ladders.
export (int) var fly_speed = 20
export (int) var fly_accel = 4
export (bool) var is_flying = false

# Gravity variables
export (float) var gravity = -9.8
# Has to be negative as it is added to the gravity
export (int) var gravity_fall_coef = -0

# Walking variables.
export (int) var walk_speed = 20
export (int) var sprint_speed_coef = 5
export (int) var crouch_speed = 10
export (int) var crawl_speed = 5
export (int) var acceleration = 2
export (int) var deacceleration = 6

enum PLAYER_STANCES { STANDING, CROUCHING, CRAWLING, FLYING }

export var player_stance = PLAYER_STANCES.STANDING

# Slopes variables. Used to manage behavior when walking on a slope.
export (int) var max_slope_angle = 85

# Stairs variables. Used to manage behavior when walking on stairs.
export (int) var max_stair_angle = 20
export (int) var stair_jump_height = 6

# Jumping variables.
export (int) var jump_height = 7
export (int) var max_time_in_air = 30
var time_in_air = 0;
var has_contact_with_floor = false

# Signals
signal start_walking
signal start_sprinting
signal start_flying
signal start_crouching
signal start_crawling
signal start_standing

### Godot built-in methods
func _ready():
	pass

func _physics_process(delta):
	process_camera_movement()
	move(delta)

func _input(event):
	if event is InputEventMouseMotion:
		# Gives a Vector2 that describe how far the mouse moved during the event.
		# We use the global camera_change variable so that the inputs and actual processing
		# of the camera movement that is done in the _physics_process method are synchronised as much
		# as possible
		camera_change = event.relative

### Custom methods
func move(delta):
	# Resets the player's direction
	direction = Vector3()
	
	process_movement_inputs()
	
	if player_stance != PLAYER_STANCES.FLYING:
		process_slopes_detection(delta)
		#process_stair_detection()
		process_walk_movements(delta)
	else:
		process_fly_movement(delta)

func process_camera_movement():
	if camera_change.length() > 0:
		$Head.rotate_y(deg2rad(-camera_change.x * mouse_sensitivity))
		
		var change = -camera_change.y * mouse_sensitivity
		var angle = change + camera_angle
		
		if (angle < max_camera_angle) and (angle > min_camera_angle):
			$Head/Camera.rotate_x(deg2rad(change))
			camera_angle += change
		camera_change = Vector2()

func process_movement_inputs():
	# Gets the camera rotation because the movements of the player is defined by the
	# direction he is looking at
	var camera_rotation = $Head/Camera.get_global_transform().basis
	
	if Input.is_action_pressed("move_left"):
		direction -= camera_rotation.x
	if Input.is_action_pressed("move_right"):
		direction += camera_rotation.x
	if Input.is_action_pressed("move_forward"):
		direction -= camera_rotation.z
	if Input.is_action_pressed("move_backward"):
		direction += camera_rotation.z
	
	# Allows to change the player stance and notify when
	# it happens
	if Input.is_action_just_pressed("crouch"):
		if player_stance == PLAYER_STANCES.CROUCHING:
			player_stance = PLAYER_STANCES.STANDING
			emit_signal("start_walking")
		else:
			player_stance = PLAYER_STANCES.CROUCHING
			emit_signal("start_crouching")
	elif Input.is_action_just_pressed("crawl"):
		if player_stance == PLAYER_STANCES.CRAWLING:
			player_stance = PLAYER_STANCES.CROUCHING
			emit_signal("start_crouching")
		else:
			player_stance = PLAYER_STANCES.CRAWLING
			emit_signal("start_crawling")
	elif Input.is_action_just_pressed("toggle_flying"):
		if player_stance == PLAYER_STANCES.FLYING:
			player_stance = PLAYER_STANCES.STANDING
			emit_signal("start_walking")
		else:
			player_stance = PLAYER_STANCES.FLYING
			emit_signal("start_flying")
	
	if player_stance != PLAYER_STANCES.FLYING:
		direction.y = 0
	
	# Any value of the vector that is greater than 1 will be reset to one
	# this allows to keep the direction and have a uniform movement
	direction = direction.normalized()

func process_slopes_detection(delta):
	if is_on_floor():
		has_contact_with_floor = true
		var slope_raycast_normal = $SlopeRaycast.get_collision_normal()
		var floor_angle = rad2deg(acos(slope_raycast_normal.dot(Vector3(0,1,0))))
		
		if floor_angle > max_slope_angle:
			velocity.y += (gravity + gravity_fall_coef) * delta
	else:
		if !$SlopeRaycast.is_colliding():
			has_contact_with_floor = false
		velocity.y += (gravity + gravity_fall_coef) * delta
		
	if has_contact_with_floor and !is_on_floor():
		move_and_collide(Vector3(0, -1, 0))

func process_stair_detection():
	if direction.length() > 0 and $StairRaycast.is_colliding():
		var stair_normal = $StairRaycast.get_collision_normal()
		var stair_angle = rad2deg(acos(stair_normal.dot(Vector3(0,1,0))))
		
		if stair_angle < max_stair_angle:
			velocity.y = stair_jump_height
			has_contact_with_floor = false

func process_walk_movements(delta):
	# First we need to calculate the speed to apply
	var current_velocity = velocity
	current_velocity.y = 0
	
	var speed
	
	speed = get_speed_from_stance()
	
	if Input.is_action_pressed("sprint"):
		speed += sprint_speed_coef
		emit_signal("start_sprinting")
	
	var target = direction * speed
	var accel
	
	if direction.dot(current_velocity) > 0:
		accel = acceleration
	else:
		accel = deacceleration
	
	current_velocity = current_velocity.linear_interpolate(target, accel * delta)
	
	velocity.x = current_velocity.x
	velocity.z = current_velocity.z
	
	#velocity.y += gravity * delta
	
	# We then check if the player wants to jump
	if has_contact_with_floor and Input.is_action_just_pressed("jump"):
		velocity.y = jump_height
		has_contact_with_floor = false
	
	# We can now move the player
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))
	
	if !has_contact_with_floor:
		time_in_air += 1
	
	$StairRaycast.translation.x = direction.x
	$StairRaycast.translation.z = direction.z

func process_fly_movement(delta):
	var target = direction * fly_speed
	velocity = velocity.linear_interpolate(target, fly_accel * delta)
	
	if Input.is_action_pressed("jump"):
		velocity.y = jump_height
	
	if Input.is_action_pressed("crouch"):
		velocity.y = -jump_height
	
	move_and_slide(velocity)
	
func get_speed_from_stance():
	var speed
	
	if player_stance == PLAYER_STANCES.STANDING:
		speed = walk_speed
	elif player_stance == PLAYER_STANCES.CROUCHING:
		speed = crouch_speed
	elif player_stance == PLAYER_STANCES.CRAWLING:
		speed = crawl_speed
	elif player_stance == PLAYER_STANCES.FLYING:
		speed = fly_speed
	
	return speed