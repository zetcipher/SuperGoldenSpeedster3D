extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	grabSettings()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rect_scale = Vector2.ONE * (G.screenRes.y / 480)
	
	$renderscaleoutput.text = str($RenderScale.value, "%")
	if $useTargetRes.pressed:
		$RenderScale.editable = false
		$HRes2.editable = true
		$VRes2.editable = true
		$renderscaleoutput3.text = str(Vector2($HRes2.value, $VRes2.value))
	else:
		$RenderScale.editable = true
		$HRes2.editable = false
		$VRes2.editable = false
		$renderscaleoutput3.text = str(Vector2($HRes.value, $VRes.value) * ($RenderScale.value / 100))
	pass
	

func grabSettings():
	$RenderScale.value = G.renderScale * 100
	$HRes.value = G.screenRes.x
	$VRes.value = G.screenRes.y
	$HRes2.value = G.targetRes.x
	$VRes2.value = G.targetRes.y
	$useTargetRes.pressed = G.useTargetRes
	$Filtering.pressed = G.filtering
	$Scanlines.pressed = G.scanlines

func _on_Apply_pressed():
	OS.window_size = Vector2($HRes.value, $VRes.value)
	G.screenRes = OS.window_size
	G.targetRes = Vector2($HRes2.value, $VRes2.value)
	G.useTargetRes = $useTargetRes.pressed
	G.renderScale = $RenderScale.value / 100
	G.filtering = $Filtering.pressed
	G.scanlines = $Scanlines.pressed
	
	G.saveSettings()


func _on_Close_pressed():
	self.hide()
