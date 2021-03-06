extends Node

const SETTINGS_PATH = "user://settings.config"

#Player Varibles

var p_HP : int = 5 # set by player script, used for hud
var p_MHP : int = 5
var p_boost : float = 0 # set by player script, used for hud
var p_mBoost : float = 100
var p_speed : float = 0 # set by player script, used for hud
var p_mSpeed : float = 200 # speed cap minus 20
var p_vel : Vector3 = Vector3.ZERO
var p_rot : Vector3 = Vector3.ZERO
var p_translation : Vector3 = Vector3.ZERO

var resetPlayerTranslation = false

var title = true

var coins : int = 0
var mCoins : int = 0
var gems : int = 0
var mGems : int = 0

var time := 0.0

var coinTime := 0.0
var gemTime := 0.0

#Screen Variables
onready var screenRes := OS.window_size
var renderScale := 1.0 #percent
var useTargetRes := false
var targetRes := Vector2(426,240)
var filtering := false
var scanlines := false
var AA : int = 0

var FPS = 0

var mouseLook := true
var camPath

var saveDict := {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	var settingsFile = File.new()
	if not settingsFile.file_exists(SETTINGS_PATH):
		saveSettings()
	else:
		loadSettings()

func _process(delta):
	if title:
		get_tree().paused = true
	else:
		get_tree().paused = false
	
	if title and Input.is_action_just_pressed("jump"):
		title = false
	time += delta
	
	screenRes = OS.window_size
	FPS = Engine.get_frames_per_second()
	#print(p_speed)
	pass

func reset() -> void:
	title = true
	time = 0
	coins = 0
	gems = 0
	coinTime = 0
	gemTime = 0
	get_tree().reload_current_scene()

func saveSettings() -> void:
	saveDict = {
		"screenRes" : screenRes,
		"renderScale" : renderScale,
		"useTargetRes" : useTargetRes,
		"targetRes" : targetRes,
		"filtering" : filtering,
		"scanlines" : scanlines,
		"AA" : AA,
		"mouseLook" : mouseLook
	}
	
	var file := File.new()
	file.open(SETTINGS_PATH, File.WRITE)
	file.store_string(var2str(saveDict))
	file.close()

func loadSettings() -> void:
	var file := File.new()
	file.open(SETTINGS_PATH, File.READ)
	var data: Dictionary = str2var(file.get_as_text())
	file.close()
	
	for key in data.keys():
		if data.has(key):
			set(key, data.get(key))
			if key == "screenRes":
				OS.window_size = data.get("screenRes")
				OS.center_window()
			print(key, data.get(key))
	
	if data.has("screenRes"):
		print("did i set the screen size???")
	
