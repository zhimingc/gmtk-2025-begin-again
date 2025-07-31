extends Node

@export var press_frequency : float = 4.0
@export var press_window : float = 0.25

@onready var mindful_vis : MindfulVisualizer = %MindfulVisualizer

var mindful_timer : float = 0.0

func _ready() -> void:
	restart_mindful_timer()

func restart_mindful_timer() -> void:
	mindful_timer = press_frequency
	mindful_vis.loop_visualization()

func _process(delta: float) -> void:
	mindful_timer -= delta
	if mindful_timer <= 0.0:
		restart_mindful_timer()
	mindful_vis.update_visualization(get_mindful_press_progress())

	if Input.is_action_just_pressed("mindful_input"):
		# check if the press is within 0.0 +/- press window
		if mindful_timer < press_window or press_frequency - mindful_timer < press_window:
			mindful_vis.trigger_good_press()
		else:
			mindful_vis.trigger_bad_press()
			restart_mindful_timer()

func get_mindful_press_progress() -> float:
	return mindful_timer/press_frequency
