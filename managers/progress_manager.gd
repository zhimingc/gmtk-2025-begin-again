class_name ProgressManager extends Node

enum PRESS_PROG { START = 0, FIRST = 4, SECOND = 8, THIRD = 12, FOURTH = 16, FIFTH = 20, DONE = 25}
# enum PRESS_PROG { START = 0, FIRST = 2, SECOND = 4, THIRD = 6, FOURTH = 8, FIFTH = 12, DONE = 16} # debugging
# enum PRESS_PROG { START = 0, FIRST = 1, SECOND = 2, THIRD = 3, FOURTH = 4, FIFTH = 5, DONE = 6} # debugging fast

signal broadcast_progress_done()

@export var metronome_tracks : Array[AudioStream]

@onready var mindful_manager : MindfulManager = %MindfulManager
@onready var mindful_vis : MindfulVisualizer = %MindfulVisualizer
@onready var presses_label : RichTextLabel = %PressesLabel
@onready var metronome_player : AudioStreamPlayer = %MetronomePlayer
@onready var progress_dots : ProgressDots = %ProgressDots
@onready var hardcore_toggle : CheckButton = %HardToggle

var good_presses : int = 0
var last_stage : PRESS_PROG = PRESS_PROG.START

func _ready() -> void:
	mindful_manager.connect("broadcast_good_press", on_good_press)
	mindful_manager.connect("broadcast_bad_press", on_bad_press)
	mindful_manager.connect("broadcast_running", on_game_running)
	mindful_manager.connect("broadcast_idle", on_game_idle)
	mindful_manager.connect("broadcast_restarting", on_game_restart)
	set_presses_label()

func on_game_idle() -> void:
	reset_progress()

func on_game_running() -> void:
	metronome_player.play(0.0)
	reset_progress_from_stage(last_stage)

func on_game_restart() -> void:
	metronome_player.stop()

func on_bad_press() -> void:
	reset_progress_from_stage(last_stage)

func on_good_press() -> void:
	good_presses += 1
	set_presses_label()
	update_progress(good_presses)
	if good_presses < PRESS_PROG.FOURTH and metronome_player.playing:
		metronome_player.play(0.0)

func update_progress(presses : int) -> void:
	match presses:
		PRESS_PROG.FIRST:
			mindful_vis.remove_good_press_area()
		PRESS_PROG.SECOND:
			mindful_vis.disturb_timer_circle_fade = true
		PRESS_PROG.THIRD: # remove all metronome
			metronome_player.stream = metronome_tracks[1]
			metronome_player.play(0.0)
		PRESS_PROG.FOURTH:
			metronome_player.stop()
		PRESS_PROG.FIFTH: # blackout
			mindful_vis.trigger_blackout()
		PRESS_PROG.DONE:
			progress_dots.set_done()
			emit_signal("broadcast_progress_done")
			pass

	var stage = PRESS_PROG.values().find(good_presses)
	if stage != -1:
		if !hardcore_toggle.pressed:
			last_stage = PRESS_PROG.values()[stage]
		progress_dots.set_progress_hud(stage)

func reset_progress_from_stage(stage : PRESS_PROG) -> void:
	good_presses = stage
	set_presses_label()
	if good_presses < PRESS_PROG.FOURTH and metronome_player.playing:
		metronome_player.play(0.0)
	else:
		metronome_player.stop()
	if hardcore_toggle.button_pressed:
		reset_audio_assist()
		metronome_player.play(0.0)
		mindful_vis.reset_visualisation()
		progress_dots.set_progress_hud(stage)

func reset_progress() -> void:
	good_presses = 0
	last_stage = PRESS_PROG.START
	set_presses_label()
	reset_audio_assist()
	mindful_vis.reset_visualisation()
	progress_dots.set_progress_hud(0)

func reset_audio_assist() -> void:
	metronome_player.stop()
	metronome_player.stream = metronome_tracks[0]

func set_presses_label() -> void:
	presses_label.text = str(good_presses)
