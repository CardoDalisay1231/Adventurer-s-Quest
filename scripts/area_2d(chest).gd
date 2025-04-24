extends Area2D

var has_spoken = false

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if has_spoken:
		return

	if body.name == "player" and body.has_method("say"):
		has_spoken = true
		body.say("I can’t open this yet… I need to explore more.")
