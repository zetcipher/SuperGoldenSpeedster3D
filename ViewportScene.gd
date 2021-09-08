extends Node2D


var viewScale: float

var settingsBuffer:= 5


# Called when the node enters the scene tree for the first time.
func _ready():
	viewScale = OS.window_size.y / 240
	$viewportMesh.get_mesh().size = OS.window_size
	$viewportMesh.position = OS.window_size / 2
	$CanvasLayer/scanlineMesh.get_mesh().size = OS.window_size
	$CanvasLayer/scanlineMesh.position = OS.window_size / 2
	print($Viewport.msaa)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not G.title:
		$CanvasLayer/title.hide()
	
	if G.camPath != null:
		get_node(G.camPath).mouse_enabled = G.mouseLook
	
	$CanvasLayer/title.scale = Vector2(OS.window_size.x / 426, OS.window_size.y / 240)
	viewScale = OS.window_size.y / 240
	$viewportMesh.get_mesh().size = OS.window_size
	$viewportMesh.position = OS.window_size / 2
	$CanvasLayer/scanlineMesh.get_mesh().size = OS.window_size
	$CanvasLayer/scanlineMesh.position = OS.window_size / 2
	if G.useTargetRes:
		$Viewport.size = G.targetRes
	else:
		$Viewport.size = OS.window_size * G.renderScale
	if G.filtering:
		$viewportMesh.get_texture().set_flags(4)
	else:
		$viewportMesh.get_texture().set_flags(0)
	
	if G.scanlines:
		$CanvasLayer/scanlineMesh.show()
	else:
		$CanvasLayer/scanlineMesh.hide()
	
	$Viewport.msaa = G.AA
	if G.AA <= 0:
		$Viewport.fxaa = false
	else:
		$Viewport.fxaa = true
	
	if Input.is_action_just_pressed("pause") and settingsBuffer >= 5:
		if $CanvasLayer/Settings.visible == true:
			$CanvasLayer/Settings.hide()
		else:
			$CanvasLayer/Settings.grabSettings()
			$CanvasLayer/Settings.show()
		settingsBuffer = 0
	
	if settingsBuffer < 5:
		settingsBuffer += 1
	

func _input(event):  # this allows overriding through inheritance
	if G.camPath != null:
		get_node(G.camPath).call("_input", event)
