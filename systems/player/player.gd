class_name PlayerController
extends CharacterBody2D
## Reusable movement controller; room geometry is supplied by scene composition.

@export var move_speed: float = 220.0
@export var jump_speed: float = 420.0
@export var gravity: float = 1200.0
@export_range(1.0, 1000.0, 1.0) var roll_speed: float = 500.0
@export_range(0.01, 1.0, 0.01) var roll_duration: float = 0.2

var is_rolling: bool:
	get:
		return _roll_time_left > 0.0

## Read-only i-frame stub; a future damage receiver can consult this flag.
var is_invincible: bool:
	get:
		return is_rolling

var _facing_direction: float = 1.0
var _roll_direction: float = 1.0
var _roll_time_left: float = 0.0


func _physics_process(delta: float) -> void:
	_roll_time_left = maxf(0.0, _roll_time_left - delta)
	var move_direction: float = Input.get_axis("move_left", "move_right")
	if not is_rolling:
		if not is_zero_approx(move_direction):
			_facing_direction = signf(move_direction)
		if Input.is_action_just_pressed("roll") and is_on_floor():
			_roll_direction = _facing_direction
			_roll_time_left = roll_duration
			# TODO: Allow roll to cancel attack recovery once attacks exist.

	if not is_on_floor():
		velocity.y += gravity * delta

	if not is_rolling and Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_speed

	# Lock the burst direction, then immediately restore knife-1 movement on expiry.
	# With no move input, the first non-roll frame has zero horizontal velocity.
	velocity.x = _roll_direction * roll_speed if is_rolling else move_direction * move_speed
	move_and_slide()
