extends KinematicBody

const MIN_SPEED := 1
const TOP_SPEED := 15
const TOP_SPEED2 := 30
const TOP_SPEED3 := 45
const ACCEL := 20
const ACCEL2 := 7.5
const ACCEL3 := 2.5
const DECEL := 45
const SHARP_DECEL := 80
const TOP_DECEL := 0.25
const AIR_ACCEL := 10
const AIR_IDLE_DECEL := 2.5
const TURN_SPEED := 180
const AIR_TURN_SPEED := 240
const SHARP_TURN_THRESHOLD := 140
const JUMP_FORCE := 30
const UP_VEC := Vector3(0, 1, 0)

var velocity : Vector3 = Vector3.ZERO
var vel1: Vector3 = Vector3.ZERO
var vel2: Vector3 = Vector3.ZERO
var snapVec : Vector3 = Vector3.ZERO
var floorRot : Vector3 = Vector3.ZERO
var floorNorm : Vector3 = Vector3.UP
var floorMaxAngle : float = 45

var targetSpeed : float = 0

var moveLeftStrength : float = 0
var moveRightStrength : float = 0
var moveUpStrength : float = 0
var moveDownStrength : float = 0

var gravityVector = Vector3.DOWN
onready var gravityStrength = 75
onready var intialPos = translation

var slopeAccelMult : float = 1

onready var camera = $CameraContainer/TrackballCamera

var HP : int = 5
var mHP : int = 5

var boost : float = 0
var mBoost : float = 100



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
	
	#var vv = vel2 #'vertical' velocity
	var vv = Vector3(0, vel2.y, 0) #'vertical' velocity
	var hv = vel1 #'horizontal' velocity
	
	var hdir = hv.normalized() #horizontal direction
	var hspeed = hv.length() #horizonstal speed
	
	#player input
	var camBasis = camera.get_global_transform().basis
	var dir := Vector3()
	
#	var angle : float
	dir = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * camBasis[0]
	dir += (Input.get_action_strength("move_down") - Input.get_action_strength("move_up")) * camBasis[2]
	
	var topSpeedMod = dir.length()
	#print(topSpeedMod)
#	dir = (Input.get_action_strength("move_up") - Input.get_action_strength("move_down")) * camBasis[0]
#	dir += (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * camBasis[2]
	
#	dir.x = (moveRightStrength - moveLeftStrength) * camBasis.x
#	dir.z = (moveDownStrength - moveUpStrength) * camBasis.z
	#dir.y = 0
	dir = dir.slide(floorNorm)
	
	dir = dir.normalized()
	
	var jumpAttempt = Input.is_action_just_pressed("jump")
	
	var sharp_turn = hspeed > 0.1 and rad2deg(acos(dir.dot(hdir))) > SHARP_TURN_THRESHOLD
	var floorAngle := Vector3()
	var upvector := Vector3()
	
	#print(self.rotation, $CameraContainer.rotation)
	if is_on_floor():
		if floorNorm.y < 0.8:
			floorMaxAngle = 180
		else:
			floorMaxAngle = 80
			self.rotation.y = 0
		#self.rotation = floorRot
		upvector = floorNorm
#		gravityVector = -floorNorm
		gravityVector = Vector3.DOWN
		#print(get_floor_normal())
	else:
		self.rotation.y = 0
		floorMaxAngle = 80
		gravityVector = Vector3.DOWN
		upvector = Vector3.UP
		floorNorm = Vector3.UP
	
	slopeAccelMult = -dir.y + 1
	print(slopeAccelMult)
	
	if not is_on_floor() and Input.is_action_just_pressed("action2"):
		hspeed = 0
		vv = 80 * Vector3.DOWN
	
	if not is_on_floor():
		vv += gravityVector * (delta * gravityStrength)
	elif not jumpAttempt:
		vv += gravityVector * (delta * gravityStrength / 8)
		if vv.y < -12:
			vv.y = -12
	
	if dir.length() > 0.05 and not sharp_turn:
		if hspeed > 0.001:
			if is_on_floor():
				hdir = adjust_facing(hdir, dir, delta, 1.0 / hspeed * TURN_SPEED, floorNorm)
			else:
				hdir = adjust_facing(hdir, dir, delta, 1.0 / hspeed * AIR_TURN_SPEED, floorNorm)
		else:
			hdir = dir
		
		if hspeed < TOP_SPEED:
			if is_on_floor():
				hspeed += ACCEL * delta * slopeAccelMult
			else:
				hspeed += AIR_ACCEL * delta
		if hspeed > TOP_SPEED and hspeed < TOP_SPEED2:
			hspeed += ACCEL2 * delta * slopeAccelMult
		if hspeed > TOP_SPEED2 and hspeed < TOP_SPEED3:
			hspeed += ACCEL3 * delta * slopeAccelMult
		if hspeed > TOP_SPEED3:
			hspeed -= TOP_DECEL * delta * slopeAccelMult
	else:
		if dir.length() > 0.05:
			if is_on_floor():
				hspeed -= SHARP_DECEL * delta * slopeAccelMult
			else:
				hspeed -= SHARP_DECEL * delta
		elif not is_on_floor():
			hspeed -= AIR_IDLE_DECEL * delta
		else:
			hspeed -= DECEL * delta * slopeAccelMult
		if hspeed < 0:
			hspeed = 0
		if hspeed > 120:
			hspeed = 120
#	var dirXform : Transform
#	dirXform = Transform(Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1), hdir)
#	dirXform = align_with_y(dirXform, floorNorm)
	
	var boostButton = Input.is_action_pressed("action1")
	var boostReleased = Input.is_action_just_released("action1")
	var trailTimer: float
	
	if hspeed > TOP_SPEED3 - 1 and trailTimer < 3:
		trailTimer = 2
	if boostButton and boost < mBoost + 10:
		boost += (75 / (hspeed * 0.015 + 0.5)) * delta
	if boostReleased and boost >= mBoost - 2 and hspeed > 0.05:
		var boostamt = (100 / (hspeed * 0.25 + 1))
		if boostamt > 30:
			boostamt = 30
		if boostamt < 5:
			boostamt = 5
		print(boostamt)
		hspeed += boostamt
		trailTimer = 10
		boost = 0
	if not boostButton:
		boost = 0
	
	if trailTimer > 0:
		if trailTimer > 3:
			$Trail3D.base_width = 1
		else:
			$Trail3D.base_width = 0.5
		trailTimer -= delta
		$Trail3D.lifetime = 0.25
	elif $Trail3D.lifetime > 0:
		$Trail3D.lifetime -= delta * 0.2
	
	#print(trailTimer)
	
	#print(hspeed)
	hv = hdir * hspeed
	
	
		
	#print(floorAngle, "   ", floorNorm)
	#var velRot: float
	
	var meshXform = $container.get_transform()
	var facingMesh = -meshXform.basis[0].normalized()
	facingMesh = (facingMesh - upvector * facingMesh.dot(upvector)).normalized()
	
	if hspeed > 0:
		facingMesh = adjust_facing(facingMesh, dir, delta, 1.0 / hspeed * TURN_SPEED, upvector)
	var m3 = Basis(-facingMesh, upvector, -facingMesh.cross(upvector).normalized()).scaled(Vector3.ONE)
	
	$container.set_transform(Transform(m3, meshXform.origin))
	
	#$CameraContainer.rotation = -rotation
	#print($CameraContainer.rotation_degrees)

	if jumpAttempt and is_on_floor():
		snapVec = Vector3.ZERO
		var jumpVel = (JUMP_FORCE * (1 + hspeed / 150)) * floorNorm
		hv.x += jumpVel.x
		vv.y += jumpVel.y
		hv.z += jumpVel.z
		floorNorm = Vector3.UP
		upvector = Vector3.UP
	# Assign hvel's values back to velocity, and then move.
	if not is_on_floor():
		vv.y += hv.y / 2
	vel1 = hv
	vel2 = vv
	
	velocity = hv + vv
#	velocity.x = hv.x
#	velocity.z = hv.z
	
	#velocity = velocity.rotated(floorNorm, 1)
	#velocity = velocity.rotated(upvector, 1)
	velocity = move_and_slide_with_snap(velocity, snapVec, Vector3.UP, false, 4, deg2rad(floorMaxAngle))
	G.p_vel = velocity
	G.p_rot = rotation_degrees
	
	if $CollisionCapsule/RayCast.get_collider() != null:
		floorRot = $CollisionCapsule/RayCast.get_collider().rotation
		floorNorm = $CollisionCapsule/RayCast.get_collision_normal()
	else:
		floorRot = Vector3.ZERO
		floorNorm = Vector3.UP
	var xform = align_with_y($CollisionCapsule.get_global_transform(), floorNorm)
	
	$CollisionCapsule.set_global_transform($CollisionCapsule.global_transform.interpolate_with(xform, 0.4))
	$container.scale = Vector3.ONE
	$direction.rotation = -rotation
	$direction.cast_to = dir * 3
	
	#velocity = move_and_slide(velocity, UP_VEC, false, 4, deg2rad(70))
	var slides = get_slide_count()
#	if slides:
#		slope(slides)
	
	if not is_on_floor():
		snapVec = Vector3.ZERO
	else:
		snapVec = -floorNorm * 2
		#velocity += gravityVector * (delta * (gravityStrength / ((hspeed + 0.5) * 0.5)))
	
	if velocity.y > 120:
		velocity.y = 120
	if velocity.y < -120:
		velocity.y = -120
	
	var new_anim := ""
	if hspeed < 0.05:
		new_anim = "IdleAnim"
		$container/playermodel/AnimationPlayer.playback_speed = 1
	else:
		$container/playermodel/AnimationPlayer.playback_speed = 1 + (hspeed / 7)
		new_anim = "RunningAnim"
	
	if $container/playermodel/AnimationPlayer.current_animation != new_anim:
		$container/playermodel/AnimationPlayer.play(new_anim)
	
	
	
	if is_on_floor():
		G.p_speed = hspeed
	else:
		G.p_speed = hspeed
	
	G.p_boost = boost
	G.p_HP = HP
	
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
