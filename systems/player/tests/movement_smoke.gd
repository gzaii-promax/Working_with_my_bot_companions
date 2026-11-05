extends SceneTree
## Run with: godot --headless --script res://systems/player/tests/movement_smoke.gd

var failures: int = 0


func _initialize() -> void:
	run.call_deferred()


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func frames(count: int) -> void:
	for frame in range(count):
		await physics_frame
		await process_frame


func key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)


func check_rolls(player: PlayerController) -> void:
	check(InputMap.has_action("roll"), "InputMap must define roll")
	check(not player.is_rolling and not player.is_invincible, "Idle must not grant i-frames")
	var start_x: float = player.position.x
	key(KEY_SHIFT, true)
	await frames(1)
	check(player.is_rolling and player.is_invincible, "Shift must start a roll with i-frames")
	check(player.velocity.x > player.move_speed, "Idle roll must burst in the default right-facing direction")
	key(KEY_SHIFT, false)
	var roll_frames: int = 1
	while player.is_rolling and roll_frames < 60:
		check(player.is_invincible, "I-frames must last throughout the roll")
		await frames(1)
		roll_frames += 1
	check(not player.is_rolling and not player.is_invincible, "Roll and i-frames must end together")
	check(player.position.x > start_x + 60.0, "Roll must move the player horizontally")
	check(roll_frames <= 15, "Default roll must recover after about 0.2 seconds at 60 Hz")
	check(is_zero_approx(player.velocity.x), "First recovered frame must stop without move input")
	var stopped_x: float = player.position.x
	await frames(5)
	check(is_equal_approx(player.position.x, stopped_x), "Roll recovery must not slide")

	# Current move input takes precedence over the previous facing direction.
	key(KEY_LEFT, true)
	key(KEY_SHIFT, true)
	await frames(1)
	check(player.is_rolling and player.velocity.x < -player.move_speed, "Move-left plus Shift must roll left")
	key(KEY_LEFT, false)
	key(KEY_SHIFT, false)
	await frames(20)
	check(player.position.x < stopped_x - 60.0, "Left roll must continue after releasing move")
	check(not player.is_invincible and is_zero_approx(player.velocity.x), "Left roll must recover to idle")

	# Facing persists while idle, and holding Shift never starts another roll.
	key(KEY_SHIFT, true)
	await frames(1)
	check(player.is_rolling and player.velocity.x < 0.0, "Idle roll must remember left-facing direction")
	await frames(20)
	stopped_x = player.position.x
	await frames(20)
	check(not player.is_rolling and not player.is_invincible, "Holding Shift must not repeat the roll")
	check(is_equal_approx(player.position.x, stopped_x), "Held Shift must leave the recovered player stationary")
	key(KEY_SHIFT, false)
	await frames(1)

	# Changing direction or pressing jump must not interrupt the active burst.
	key(KEY_RIGHT, true)
	key(KEY_SHIFT, true)
	await frames(1)
	check(player.is_rolling and player.velocity.x > 0.0, "A fresh Shift press must allow another grounded roll")
	key(KEY_RIGHT, false)
	key(KEY_LEFT, true)
	key(KEY_SPACE, true)
	await frames(3)
	check(player.velocity.x > player.move_speed and player.is_invincible, "Opposite input must not reverse the active roll")
	check(player.is_on_floor(), "Jump must not interrupt a grounded roll")
	key(KEY_SHIFT, false)
	key(KEY_SPACE, false)
	await frames(20)
	check(not player.is_rolling and not player.is_invincible, "Recovery must clear roll state with move held")
	check(is_equal_approx(player.velocity.x, -player.move_speed), "Recovery must immediately resume held move input")
	key(KEY_LEFT, false)
	await frames(1)
	check(is_zero_approx(player.velocity.x), "Releasing move after recovery must stop immediately")


func run() -> void:
	check(Engine.physics_ticks_per_second == 60, "Movement smoke expects the default 60 Hz physics tick")
	var scene: PackedScene = load(ProjectSettings.get_setting("application/run/main_scene"))
	var main: Node = scene.instantiate()
	root.add_child(main)
	var player: PlayerController = main.get_node("Player")
	check(main.get_node("Sandbox/Floor") is StaticBody2D, "Room must have a static floor")
	await frames(40)
	check(player.is_on_floor(), "Player must land on the floor")
	await check_rolls(player)
	var floor_y: float = player.position.y
	var start_x: float = player.position.x
	key(KEY_RIGHT, true)
	await frames(10)
	check(player.position.x > start_x + 20.0, "Right arrow must move right via InputMap")
	key(KEY_RIGHT, false)
	await frames(2)
	var stopped_x: float = player.position.x
	await frames(5)
	check(is_equal_approx(player.position.x, stopped_x), "Release must stop horizontal drift")
	key(KEY_LEFT, true)
	await frames(10)
	check(player.position.x < stopped_x - 20.0, "Left arrow must move left via InputMap")
	key(KEY_LEFT, false)
	key(KEY_SPACE, true)
	await frames(5)
	check(player.position.y < floor_y - 10.0 and player.velocity.y < 0.0, "Space must jump")
	key(KEY_SPACE, false)
	key(KEY_SHIFT, true)
	await frames(1)
	check(not player.is_rolling and not player.is_invincible, "Airborne Shift must not start a roll or i-frames")
	await frames(3)
	var rising_velocity: float = player.velocity.y
	key(KEY_SPACE, true)
	await frames(2)
	check(player.velocity.y > rising_velocity, "A second airborne press must not reset jump velocity")
	# Holding jump through landing must not trigger an automatic second jump.
	for frame in range(60):
		await frames(1)
		check(not player.is_rolling and not player.is_invincible, "Holding airborne Shift through landing must not trigger a roll")
	check(player.is_on_floor(), "Player must land even with jump held")
	check(absf(player.position.y - floor_y) < 1.0, "Player must not sink through floor")
	key(KEY_SHIFT, false)
	key(KEY_SPACE, false)
	await frames(2)
	key(KEY_SPACE, true)
	await frames(5)
	check(player.velocity.y < 0.0, "A new grounded press must jump again")
	key(KEY_SPACE, false)
	await frames(60)
	key(KEY_LEFT, true)
	await frames(80)
	check(player.position.x >= 15.0 and player.is_on_floor(), "Left wall must keep player in room")
	key(KEY_LEFT, false)
	key(KEY_RIGHT, true)
	await frames(280)
	check(player.position.x <= 945.0 and player.is_on_floor(), "Right wall must keep player in room")
	key(KEY_RIGHT, false)
	key(KEY_SHIFT, true)
	await frames(1)
	check(player.is_rolling and player.is_invincible, "A roll against a wall must still expose its i-frame window")
	key(KEY_SHIFT, false)
	await frames(20)
	check(player.position.x <= 945.0 and player.is_on_floor(), "Roll must respect room collisions")
	check(not player.is_rolling and not player.is_invincible, "A blocked roll must expire normally")
	if failures == 0:
		print("PASS: floor, InputMap movement/roll, immediate stop, roll directions/recovery/i-frames, no held/air roll, jump, no air jump, landing, repeat jump, room bounds")
	quit(0 if failures == 0 else 1)
