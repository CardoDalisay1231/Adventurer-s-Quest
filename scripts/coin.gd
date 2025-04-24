extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var pickup_sound: AudioStreamPlayer2D = $Pickup

var collected := false

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if collected:
		return

	if body.name == "player":
		collected = true
		sprite.visible = false
		call_deferred("_disable_collision")

		pickup_sound.play()

		if not Global.first_coin_collected and body.has_method("say"):
			Global.first_coin_collected = true
			body.say("Oooh! A coin… Do I need to collect these?")
			await get_tree().create_timer(2.5).timeout
		else:
			# Wait a short time to let the sound play
			await get_tree().create_timer(0.6).timeout

		queue_free()

func _disable_collision():
	collision.disabled = true
