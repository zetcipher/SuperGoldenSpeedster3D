extends KinematicBody

const MIN_SPEED := 1
const TOP_SPEED := 20
const TOP_SPEED2 := 40
const TOP_SPEED3 := 60
const ACCEL := 15
const ACCEL2 := 7.5
const ACCEL3 := 2.5
const DECEL := 30
const SHARP_DECEL := 60
const AIR_ACCEL := 10
const AIR_IDLE_DECEL := 2.5
const TURN_SPEED := 140
const AIR_TURN_SPEED := 200
const SHARP_TURN_THRESHOLD := 120
const JUMP_FORCE := 25
const UP_VEC := Vector3(0, 1, 0)

var velocity : Vector3 = Vector3.ZERO
var snapVec : Vector3 = Vector3.ZERO
var floorRot : Vector3 = Vector3.ZERO
var floorNorm : Vector3 = Vector3.UP

var targetSpeed : float = 0

var moveLeftStrength : float = 0
var moveRightStrength : float = 0
var moveUpStrength : float = 0
var moveDownStrength : float = 0

var gravityVector = Vector3.DOWN
onready var gravityStrength = 45
onready var intialPos = translation

onready var camera = $CameraContainer/TrackballCamera


# Called when the node enters the scene tree for the first time.
func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	moveLeftStrength = Input.get_action_strength("move_left")
	moveRightStrength = Input.get_action_strength("move_right")
	moveUpStrength = Input.get_action_strength("move_up")
	moveDownStrength = Input.get_action_strength("move_down")
	
	var vv = velocity.y #vertical velocity
	var hv = Vector3(velocity.x, 0, velocity.z) #horizontal velocity
	
	var hdir = hv.normalized() #horizontal direction
	var hspeed = hv.length() #horizonstal speed
	
	#player input
	var camBasis = camera.get_global_transform().basis
	var dir := Vector3()
	
#	var angle : float
	dir = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * camBasis[0]
	dir += (Input.get_action_strength("move_down") - Input.get_action_strength("move_up")) * camBasis[2]
#	dir.x = (moveRightStrength - moveLeftStrength) * camBasis.x
#	dir.z = (moveDownStrength - moveUpStrength) * camBasis.z
	dir.y = 0
	dir = dir.normalized()
	
	var jumpAttempt = Input.is_action_just_pressed("ui_accept")
	
	var sharp_turn = hspeed > 0.1 and rad2deg(acos(dir.dot(hdir))) > SHARP_TURN_THRESHOLD
	
	if dir.length() > 0.05 and not sharp_turn:
		if hspeed > 0.001:
			if is_on_floor():
				hdir = adjust_facing(hdir, dir, delta, 1.0 / hspeed * TURN_SPEED, Vector3.UP)
			else:
				hdir = adjust_facing(hdir, dir, delta, 1.0 / hspeed * AIR_TURN_SPEED, Vector3.UP)
		else:
			hdir = dir
		
		if hspeed < TOP_SPEED:
			if is_on_floor():
				hspeed += ACCEL * delta
			else:
				hspeed += AIR_ACCEL * delta
		if hspeed > TOP_SPEED and hspeed < TOP_SPEED2:
			hspeed += ACCEL2 * delta
		if hspeed > TOP_SPEED2 and hspeed < TOP_SPEED3:
			hspeed += ACCEL3 * delta
	else:
		if dir.length() > 0.05:
			hspeed -= SHARP_DECEL * delta
		elif not is_on_floor():
			hspeed -= AIR_IDLE_DECEL * delta
		else:
			hspeed -= DECEL * delta
		if hspeed < 0:
			hspeed = 0
	
	print(hspeed)
	hv = hdir * hspeed
	
	var floorAngle := Vector3()
	var upvector := Vector3()
	if $RayCast.get_collider() != null:
		floorRot = $RayCast.get_collider().rotation
		floorNorm = $RayCast.get_collision_normal()
		
	#print(floorAngle, "   ", floorNorm)
	#var velRot: float
	var xform = align_with_y(global_transform, floorNorm)
	global_transform = global_transform.interpolate_with(xform, 0.2)
	if is_on_floor():
		#self.rotation = floorRot
		upvector = floorNorm
#		gravityVector = -floorNorm
		gravityVector = Vector3.DOWN
		#print(get_floor_normal())
	else:
		gravityVector = Vector3.DOWN
		upvector = Vector3.UP
		floorNorm = Vector3.UP
	
	var meshXform = $container.get_transform()
	var facingMesh = -meshXform.basis[0].normalized()
	facingMesh = (facingMesh - UP_VEC * facingMesh.dot(UP_VEC)).normalized()
	
	if hspeed > 0:
		facingMesh = adjust_facing(facingMesh, dir, delta, 1.0 / hspeed * TURN_SPEED, Vector3.UP)
	var m3 = Basis(-facingMesh, Vector3.UP, -facingMesh.cross(Vector3.UP).normalized()).scaled(Vector3.ONE)
	
	$container.set_transform(Transform(m3, meshXform.origin))
	
	$CameraContainer.rotation = -rotation

	# Assign hvel's values back to velocity, and then move.
	velocity.x = hv.x
	velocity.z = hv.z
	
	#velocity = velocity.rotated(upvector, 1)
	velocity = move_and_slide_with_snap(velocity, snapVec, Vector3.UP, false, 4, deg2rad(180))
	#velocity = move_and_slide(velocity, UP_VEC, false, 4, deg2rad(70))
	var slides = get_slide_count()
#	if slides:
#		slope(slides)
	
	if not is_on_floor():
		snapVec = Vector3.ZERO
	else:
		snapVec = -floorNorm * 2
	
	if jumpAttempt and is_on_floor():
		snapVec = Vector3.ZERO
		velocity += (JUMP_FORCE * (1 + hspeed / 100)) * floorNorm
	
	if not is_on_floor():
		velocity += gravityVector * (delta * gravityStrength)
	else:
		velocity += gravityVector * (delta * (gravityStrength / ((hspeed + 1.5) * 0.5)))
	
	var new_anim := ""
	if hspeed < 0.05:
		new_anim = "IdleAnim"
		$container/playermodel/AnimationPlayer.playback_speed = 1
	else:
		$container/playermodel/AnimationPlayer.playback_speed = 1 + (hspeed / 7)
		new_anim = "RunningAnim"
	
	if $container/playermodel/AnimationPlayer.current_animation != new_anim:
		$container/playermodel/AnimationPlayer.play(new_anim)
	
	
#	if Input.is_action_pressed("ui_select"):
#		$CollisionShape2.shape.slips_on_slope = true
#	else:
#		$CollisionShape2.shape.slips_on_slope = false

#func _process(delta):
#	if Input.is_action_pressed("alt"):
#		camera.mouse_enabled = false
#		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#	else:
#		camera.mouse_enabled = true
#		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform

func slope(slides : int):
	for i in slides:
		var touched = get_slide_collision(i)
		if is_on_floor() and touched.normal.y < 1.0 and (velocity.x != 0.0 or velocity.z != 0.0):
			velocity.y = touched.normal.y

#i just stole this from the platformer3d demo lol i couldn't tell you how this works
func adjust_facing(p_facing, p_target, p_step, p_adjust_rate, current_gn):
	var n = p_target # Normal.
	var t = n.cross(current_gn).normalized()

	var x = n.dot(p_facing)
	var y = t.dot(p_facing)

	var ang = atan2(y,x)

	if abs(ang) < 0.001: # Too small.
		return p_facing

	var s = sign(ang)
	ang = ang * s
	var turn = ang * p_adjust_rate * p_step
	var a
	if ang < turn:
		a = ang
	else:
		a = turn
	ang = (ang - a) * s

	return (n * cos(ang) + t * sin(ang)) * p_facing.length()
