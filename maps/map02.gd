extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	G.mGems = $WorldEnvironment/gems.get_child_count()
	G.mCoins = $WorldEnvironment/coins.get_child_count()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not G.title:
		$WorldEnvironment/Camera.current = false
		$WorldEnvironment/PlayerController/CameraContainer/TrackballCamera.current = true
