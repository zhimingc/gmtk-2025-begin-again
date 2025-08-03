class_name MindfulManager extends Node

signal broadcast_idle()
signal broadcast_running()
signal broadcast_game_starting()
signal broadcast_restarting()
signal broadcast_good_press()
signal broadcast_bad_press()

enum MINDFUL_STATE { DISABLE, IDLE, RUNNING, RESTARTING, DONE, RETURN }

@export var press_frequency : float = 4.0
@export var before_press_window : float = 0.3
@export var after_press_window : float = 0.1

@onready var mindful_vis : MindfulVisualizer = %MindfulVisualizer

var new_loop : bool = true
var pressed_for_loop : bool = true
var mindful_timer : float = 0.0
var mindful_state : MINDFUL_STATE = MINDFUL_STATE.IDLE

func _ready() -> void:
	set_mindful_state(MINDFUL_STATE.DISABLE)
	%ProgressManager.connect("broadcast_progress_done", on_progress_done)


func on_progress_done() -> void:
	set_mindful_state(MINDFUL_STATE.DONE)

func set_mindful_state(new_state : MINDFUL_STATE) -> void:
	mindful_state = new_state
	match mindful_state:
		MINDFUL_STATE.IDLE:
			mindful_timer = 0.0
			new_loop = true
			pressed_for_loop = true
			%BeginAgain.modulate = Color.TRANSPARENT
			%StartPrompt.visible = true
			emit_signal("broadcast_idle")
		MINDFUL_STATE.RUNNING:
			restart_mindful_timer()
			mindful_vis.trigger_good_press()
			%StartPrompt.visible = false
			%PressAudioPlayer.play()
			emit_signal("broadcast_running")
		MINDFUL_STATE.RESTARTING:
			mindful_timer = 0.0
			pressed_for_loop = true
			mindful_vis.trigger_begin_again()
			trigger_begin_again()
			var restart_tween = create_tween()
			restart_tween.tween_interval(4.0)
			restart_tween.tween_callback(func(): set_mindful_state(MINDFUL_STATE.RUNNING))
			emit_signal("broadcast_restarting")
		MINDFUL_STATE.DONE:
			mindful_timer = 0.0
			mindful_vis.trigger_ending_visualisation()
			restart_mindful_timer()
			var return_tween = create_tween()
			return_tween.tween_interval(4.0)
			return_tween.tween_callback(func(): set_mindful_state(MINDFUL_STATE.RETURN))

	mindful_vis.update_visualization(get_mindful_press_progress())

func trigger_begin_again() -> void:
	%BeginAgain.modulate = Color.WHITE
	var prompt_tween = create_tween()
	prompt_tween.tween_property(%BeginAgain, "modulate", Color.TRANSPARENT, 3.6)

func restart_mindful_timer() -> void:
	mindful_timer = press_frequency
	mindful_vis.loop_visualization()
	new_loop = true

func _process(delta: float) -> void:
	match mindful_state:
		MINDFUL_STATE.RUNNING:
			mindful_timer -= delta
			if mindful_timer <= 0.0:
				restart_mindful_timer()
			# check if the player pressed this loop
			if new_loop and press_frequency - mindful_timer > after_press_window:
				new_loop = false
				if not pressed_for_loop:
					mindful_vis.trigger_bad_press()
					emit_signal("broadcast_bad_press")
					set_mindful_state(MINDFUL_STATE.RESTARTING)
				else:
					pressed_for_loop = false
			mindful_vis.update_visualization(get_mindful_press_progress())

	if Input.is_action_just_pressed("mindful_input"):
		match mindful_state:
			MINDFUL_STATE.IDLE:
				set_mindful_state(MINDFUL_STATE.RESTARTING)
				%StartPrompt.visible = false
				emit_signal("broadcast_game_starting")
			MINDFUL_STATE.RUNNING:
				pressed_for_loop = true
				# check if the press is within 0.0 + press window
				if mindful_timer < before_press_window or press_frequency - mindful_timer < after_press_window:
					trigger_good_press()
				else:
					mindful_vis.trigger_bad_press()
					emit_signal("broadcast_bad_press")
					set_mindful_state(MINDFUL_STATE.RESTARTING)
			MINDFUL_STATE.RETURN:
				get_tree().reload_current_scene()
				pass
			

	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		# set_mindful_state(MINDFUL_STATE.IDLE)

	if Input.is_action_just_pressed("debug_goodpress"):
		trigger_good_press()

func trigger_good_press() -> void:
	mindful_vis.trigger_good_press()
	mindful_timer = press_frequency
	mindful_vis.loop_visualization()
	%PressAudioPlayer.play()
	emit_signal("broadcast_good_press")

func get_mindful_press_progress() -> float:
	return mindful_timer/press_frequency
