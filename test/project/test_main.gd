extends Node

const QUIT_AFTER_FRAMES := 600

var _frame := 0

func _ready() -> void:
	var test = load("res://addons/interaction_system/test/test_interaction_ui.gd").new()
	test.name = "TestInteractionUI"
	add_child(test)

func _process(_delta: float) -> void:
	_frame += 1
	if _frame == QUIT_AFTER_FRAMES:
		get_tree().quit()
