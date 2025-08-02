class_name  MindfulVisualizer extends Node2D

@export var blackout_color : Color
@export var win_color : Color

@onready var timer_circle : Sprite2D = $TimerCircle
@onready var restart_circle : Sprite2D = $RestartCircle
@onready var good_press_area : Sprite2D = $GoodPressArea
@onready var good_press_parts : CPUParticles2D = $GoodPressParticles
@onready var bad_press_parts : CPUParticles2D = $BadPressParticles
@onready var blackout_obj : Sprite2D = $Blackout

var disturb_timer_circle_fade : bool = false
var disturb_fade_tween : Tween
var feedback_circle_fade_tween : Tween
var good_press_area_color : Color

func _ready() -> void:
	good_press_area_color = good_press_area.modulate
	good_press_area.scale = Vector2.ONE * %MindfulManager.before_press_window / 4.0

func update_visualization(progress : float) -> void:
	timer_circle.scale = lerp(Vector2.ONE, Vector2.ZERO, 1.0 - progress)
	if disturb_timer_circle_fade and timer_circle.modulate == Color.WHITE and progress <= 0.5:
		disturb_fade_tween = create_tween()
		disturb_fade_tween.tween_property(timer_circle, "modulate", Color.TRANSPARENT, 0.5)

func loop_visualization() -> void:
	restart_circle.modulate = Color.TRANSPARENT
	if timer_circle:
		timer_circle.scale = Vector2.ONE
		timer_circle.modulate = Color.TRANSPARENT
		var timer_circle_fade = create_tween()
		timer_circle_fade.tween_property(timer_circle, "modulate", Color.WHITE, 0.75)

func trigger_begin_again() -> void:
	restart_circle.modulate = Color.WHITE
	var timer_circle_fade = create_tween()
	timer_circle_fade.tween_property(restart_circle, "modulate", Color.TRANSPARENT, 3.6)

func trigger_good_press() -> void:
	good_press_parts.emitting = true

func trigger_bad_press() -> void:
	trigger_feedback_circle()
	bad_press_parts.emitting = true

func trigger_ending_visualisation() -> void:
	timer_circle.visible = false
	good_press_area.modulate = Color.TRANSPARENT
	var blackout_tween = create_tween()
	blackout_tween.tween_property(blackout_obj, "modulate", Color.TRANSPARENT, 4.0)
	$FireLight1.trigger_end_game()
	$FireLight2.trigger_end_game()
	var bg_fade = create_tween()
	bg_fade.tween_property(%WinBG, "modulate", win_color, 4.0)

func reset_visualisation() -> void:
	timer_circle.visible = true
	good_press_area.modulate = good_press_area_color
	disturb_timer_circle_fade = false
	blackout_obj.modulate = Color.TRANSPARENT

func remove_good_press_area() -> void:
	var fade_tween = create_tween()
	fade_tween.tween_property(good_press_area, "modulate", Color.TRANSPARENT, 1.0)

func trigger_blackout() -> void:
	var blackout_tween = create_tween()
	blackout_tween.tween_property(blackout_obj, "modulate", blackout_color, 1.0)

func trigger_feedback_circle() -> void:
	var feedback_circle : Sprite2D = $FeedbackCircle
	feedback_circle.scale = timer_circle.scale
	if feedback_circle_fade_tween:
		feedback_circle_fade_tween.kill()
	feedback_circle.modulate = Color.DARK_RED
	feedback_circle_fade_tween = create_tween()
	feedback_circle_fade_tween.tween_property(feedback_circle, "modulate", Color.TRANSPARENT, 2.0) 
