extends RefCounted

## Unit tests for jump buffer, coyote, push timing — no scene tree physics required.


func test_coyote_constant() -> Variant:
	if absf(PlayerController.COYOTE_TIME - 0.10) > 0.001:
		return "coyote expected 0.10"
	return true


func test_jump_buffer_constant() -> Variant:
	if absf(PlayerController.JUMP_BUFFER - 0.10) > 0.001:
		return "jump buffer expected 0.10"
	return true


func test_push_duration() -> Variant:
	if absf(PlayerController.PUSH_DURATION - 0.12) > 0.001:
		return "push duration expected 0.12"
	return true


func test_game_state_flags() -> Variant:
	GameState.reset()
	if GameState.get_flag("has_milk"):
		return "milk should start false"
	GameState.set_flag("has_milk", true)
	if not GameState.get_flag("has_milk"):
		return "milk flag failed"
	GameState.reset()
	return true
