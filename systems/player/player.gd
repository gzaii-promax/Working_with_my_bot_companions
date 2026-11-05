extends CharacterBody2D
## Reusable movement controller; room geometry is supplied by scene composition.

@export var move_speed: float = 220.0
@export var jump_speed: float = 420.0
@export var gravity: float = 1200.0


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_speed

	# Immediate stop on release: no acceleration or sliding in this first slice.
	velocity.x = Input.get_axis("move_left", "move_right") * move_speed
	move_and_slide()
