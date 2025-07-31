extends Node

@export var press_frequency : float = 4.0

@onready var mindful_viz : MindfulVisualizer = %MindfulVisualizer

var mindful_timer : float = 0.0

func _ready() -> void:
	restart_mindful_timer()

func restart_mindful_timer() -> void:
	mindful_timer = press_frequency

func _process(delta: float) -> void:
	mindful_timer -= delta
	if mindful_timer <= 0.0:
		mindful_viz.loop_visualization()
		restart_mindful_timer()
	mindful_viz.update_visualization(mindful_timer/press_frequency)
		