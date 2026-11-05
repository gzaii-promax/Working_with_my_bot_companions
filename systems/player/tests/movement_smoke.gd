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


func run() -> void:
	var scene: PackedScene = load(ProjectSettings.get_setting("application/run/main_scene"))
	var main: Node = scene.instantiate()
	root.add_child(main)
	var player: CharacterBody2D = main.get_node("Player")
	check(main.get_node("Sandbox/Floor") is StaticBody2D, "Room must have a static floor")
	await frames(40)
	check(player.is_on_floor(), "Player must land on the floor")
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
	await frames(3)
	var rising_velocity: float = player.velocity.y
	key(KEY_SPACE, true)
	await frames(2)
	check(player.velocity.y > rising_velocity, "A second airborne press must not reset jump velocity")
	# Holding jump through landing must not trigger an automatic second jump.
	await frames(60)
	check(player.is_on_floor(), "Player must land even with jump held")
	check(absf(player.position.y - floor_y) < 1.0, "Player must not sink through floor")
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
	if failures == 0:
		print("PASS: floor, InputMap movement, immediate stop, jump, no air jump, landing, repeat jump, room bounds")
	quit(0 if failures == 0 else 1)
