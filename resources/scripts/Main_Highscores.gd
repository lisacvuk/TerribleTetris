extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	get_node("Your score").text = "Score: 0"
	pass
func _process(delta):
	get_node("Your score").text = "Score: " + str(get_node("../Main").score)
	pass
