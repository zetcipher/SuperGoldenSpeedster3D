extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	rotation = Vector3.ZERO
	$AnimationPlayer.play("spin")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Coin_body_entered(body):
	if body.has_method("slope"):
		print("coin collected")
		body.play_sound(1)
		G.coins += 1
		if G.coins >= G.mCoins:
			G.coinTime = G.time
		self.queue_free()
	pass # Replace with function body.
