extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta): #physics process to keep speed consistent??
	# i was going to try to animate the water somehow but i don't have time lol
	
	if G.p_translation.y < self.translation.y:
		G.resetPlayerTranslation = true
	pass
