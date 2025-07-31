class_name  MindfulVisualizer extends Node2D

@onready var timer_circle : Sprite2D = $TimerCircle
@onready var center_vis : Sprite2D = $Center
@onready var good_press_parts : CPUParticles2D = $GoodPressParticles
@onready var bad_press_parts : CPUParticles2D = $BadPressParticles

func update_visualization(progress : float) -> void:
	timer_circle.scale = Vector2.ONE * progress

func loop_visualization() -> void:
	if timer_circle:
		timer_circle.scale = Vector2.ONE
		timer_circle.modulate = Color.TRANSPARENT
		var timer_circle_fade = create_tween()
		timer_circle_fade.tween_property(timer_circle, "modulate", Color.WHITE, 0.75)

func trigger_good_press() -> void:
	# center_vis.modulate = Color.CHARTREUSE
	# var center_mod = create_tween()
	# center_mod.tween_property(center_vis, "modulate", Color.WHITE, 1.0)
	good_press_parts.emitting = true

func trigger_bad_press() -> void:
	bad_press_parts.emitting = true
	timer_circle.self_modulate = Color.DARK_RED
	var timer_circle_fade = create_tween()
	timer_circle_fade.tween_property(timer_circle, "self_modulate", Color.WHITE, 1.25)
