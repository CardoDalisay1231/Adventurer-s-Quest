extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0
const ROLL_SPEED = 200.0
const ROLL_TAP_WINDOW = 0.3 # seconds

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var speech_bubble: Label = $SpeechBubble
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var run_sound: AudioStreamPlayer2D = $RunSound

var is_attacking = false
var is_rolling = false
var last_tap_dir = 0
var last_tap_time = 0.0
var roll_dir = 0
var was_running = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta

	if _handle_attack():
		return
	if _handle_roll(delta):
		return

	_handle_jump()
	_handle_movement()

	move_and_slide()


func _handle_attack() -> bool:
	if Input.is_action_just_pressed("Attack") and is_on_floor() and not is_attacking and not is_rolling:
		_start_attack()
		return true
	
	if is_attacking:
		if not animated_sprite.is_playing():
			is_attacking = false
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		return true
	
	return false

func _handle_roll(delta: float) -> bool:
	if is_on_floor() and not is_rolling:
		if Input.is_action_just_pressed("move_right"):
			_check_tap(1)
		elif Input.is_action_just_pressed("move_left"):
			_check_tap(-1)

	if is_rolling:
		velocity.x = roll_dir * ROLL_SPEED
		move_and_slide()  # <-- THIS was missing
		if not animated_sprite.is_playing():
			is_rolling = false
		return true
	
	return false


func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sound.play()

func _handle_movement() -> void:
	var dir := Input.get_axis("move_left", "move_right")
	animated_sprite.flip_h = dir < 0

	var running = is_on_floor() and dir != 0 and not is_attacking and not is_rolling

	if running != was_running:
		if running:
			run_sound.play()
		else:
			run_sound.stop()
		was_running = running

	if is_on_floor():
		animated_sprite.play("run" if dir != 0 else "default")
	else:
		animated_sprite.play("jump")

	velocity.x = dir * SPEED if dir != 0 else move_toward(velocity.x, 0, SPEED)

func _check_tap(dir: int) -> void:
	var now = Time.get_ticks_msec() / 1000.0
	if dir == last_tap_dir and now - last_tap_time <= ROLL_TAP_WINDOW:
		_start_roll(dir)
	else:
		last_tap_dir = dir
		last_tap_time = now

func _start_roll(dir: int) -> void:
	is_rolling = true
	roll_dir = dir
	animated_sprite.flip_h = dir < 0
	animated_sprite.play("roll")
	jump_sound.play()

func _start_attack() -> void:
	is_attacking = true
	velocity.x = 0
	animated_sprite.play("attack")

func say(text: String, duration: float = 3.5) -> void:
	speech_bubble.text = text
	speech_bubble.visible = true
	await get_tree().create_timer(duration).timeout
	speech_bubble.visible = false
