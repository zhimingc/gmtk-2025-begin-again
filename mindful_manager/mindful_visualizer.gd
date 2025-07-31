class_name  MindfulVisualizer extends Node2D

@onready var timer_circle : Sprite2D = $TimerCircle

func update_visualization(progress : float) -> void:
	timer_circle.scale = Vector2.ONE * progress

func loop_visualization() -> void:
	timer_circle.scale = Vector2.ONE
	timer_circle.modulate = Color.TRANSPARENT
	var timer_circle_fade = create_tween()
	timer_circle_fade.tween_property(timer_circle, "modulate", Color.WHITE, 0.75)
