class_name ProgressManager extends Node

# 0, 40, 80, 120, 160, 200 (seconds approx.)
# 0, 10, 20, 30, 40, 50 (presses)
enum STAGES { S1, S2, S3, S4, S5 }

@export var metronome_tracks : Array[AudioStream]

@onready var mindful_manager : MindfulManager = %MindfulManager
@onready var mindful_vis : MindfulVisualizer = %MindfulVisualizer
@onready var presses_label : RichTextLabel = %PressesLabel
@onready var metronome_player : AudioStreamPlayer = %MetronomePlayer

var good_presses : int = 0
# enum PRESS_PROG { FIRST = 5, SECOND = 10, THIRD = 15, FOURTH = 20, FIFTH = 25}
# enum PRESS_PROG { FIRST = 4, SECOND = 8, THIRD = 12, FOURTH = 16, FIFTH = 20, DONE = 28}
# enum PRESS_PROG { FIRST = 2, SECOND = 4, THIRD = 6, FOURTH = 8, FIFTH = 12} # debugging
enum PRESS_PROG { FIRST = 1, SECOND = 2, THIRD = 3, FOURTH = 4, FIFTH = 5, DONE = 6} # debugging fast

func _ready() -> void:
	mindful_manager.connect("broadcast_good_press", on_good_press)
	mindful_manager.connect("broadcast_bad_press", on_bad_press)
	mindful_manager.connect("broadcast_running", on_game_running)
	set_presses_label()

func on_game_running() -> void:
	on_bad_press()

func on_bad_press() -> void:
	good_presses = 0
	set_presses_label()
	mindful_vis.reset_visualisations()
	metronome_player.stream = metronome_tracks[0]
	metronome_player.play(0.0)

func on_good_press() -> void:
	good_presses += 1
	set_presses_label()
	update_progress()

func update_progress() -> void:
	# current disturbances: 5, 10, 15, 20, 25
	# done: 35
	match good_presses:
		PRESS_PROG.FIRST:
			mindful_vis.remove_good_press_area()
		PRESS_PROG.SECOND:
			mindful_vis.disturb_timer_circle_fade = true
		PRESS_PROG.THIRD: # remove all metronome
			metronome_player.stream = metronome_tracks[1]
			metronome_player.play(0.0)
		PRESS_PROG.FOURTH: # fading timer circle vis
			metronome_player.stop()
		PRESS_PROG.FIFTH: # blackout
			mindful_vis.trigger_blackout()
		PRESS_PROG.DONE:
			pass

func set_presses_label() -> void:
	presses_label.text = str(good_presses)
