extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("spin")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_coin_body_entered(body):
	if body.has_method("slope"):
		print("coin collected")
		body.play_sound(2)
		G.gems += 1
		if G.gems >= G.mGems:
			G.gemTime = G.time
		self.queue_free()
