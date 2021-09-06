extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Control/LeftSide/FPS.text = str("FPS: ", G.FPS)
	
	var scaleFactor = 1
	scaleFactor = OS.window_size.y / 240
	scale = Vector2.ONE * scaleFactor
	$Control/RightSide.rect_position.x = OS.window_size.x / scaleFactor
	$Control/LeftSide/velocity.text = str("VX: ", G.p_vel.x)
	$Control/LeftSide/velocity2.text = str("VZ: ", G.p_vel.z)
	$Control/LeftSide/velocity3.text = str("VY: ", G.p_vel.y)
	$Control/LeftSide/rot.text = str("RX: ", G.p_rot.x)
	$Control/LeftSide/rot2.text = str("RY: ", G.p_rot.y)
	$Control/LeftSide/rot3.text = str("RZ: ", G.p_rot.z)
	$Control/LeftSide/BoostMeter.max_value = G.p_mBoost
	$Control/LeftSide/BoostMeter.value = G.p_boost
	$Control/RightSide/Speedometer.max_value = G.p_mSpeed
	$Control/RightSide/Speedometer.value = G.p_speed
	#$Control/Bars/HealthMeter.frame = G.p_HP
