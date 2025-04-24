extends Node2D



@onready var label: Label = $Label

func _ready() -> void:
	show_intro_instructions()


func show_intro_instructions() -> void:
	label.text = "Adventurer! To journey forth, remember these sacred motions:"
	
	await get_tree().create_timer(3.0).timeout

	label.text = """Walk left: ← or A
Walk right: → or D
Leap skyward: ↑ or W
Strike with honor: SPACE
Evade swiftly: Double-tap ← or →"""
