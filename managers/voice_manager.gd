class_name VoiceManager extends Node

@export var game_start_voice : AudioStream
@export var guiding_bad_press_voices : Array[AudioStream]
@export var guiding_random_voices : Array[AudioStream]
@export var doubtful_voice_ending : Array[AudioStream]
@export var doubtful_random_voices : Array[AudioStream]

@onready var mindful_manager : MindfulManager = %MindfulManager
@onready var prog_manager : ProgressManager = %ProgressManager
@onready var voice_player : AudioStreamPlayer = $VoicePlayer

var good_odds : int = 30

func _ready() -> void:
	mindful_manager.connect("broadcast_game_starting", on_game_running)
	mindful_manager.connect("broadcast_bad_press", on_bad_press)
	mindful_manager.connect("broadcast_good_press", on_good_press)

func on_game_running() -> void:
	voice_player.stream = game_start_voice
	voice_player.play(0.0)

func on_bad_press() -> void:
	voice_player.stream = guiding_bad_press_voices.pick_random()

	if prog_manager.last_stage == ProgressManager.PRESS_PROG.FIFTH:
		voice_player.stream = doubtful_voice_ending[0]

	voice_player.play(0.0)

func on_good_press() -> void:
	if prog_manager.last_stage == ProgressManager.PRESS_PROG.DONE:
		# play some ending voice here, if i get to it
		return
	
	var voice_roll = randi_range(0,100)
	if voice_roll < good_odds:
		voice_player.stream = guiding_random_voices.pick_random()
	else:
		voice_player.stream = doubtful_random_voices.pick_random()

	if prog_manager.last_stage == ProgressManager.PRESS_PROG.FIFTH:
		var num_press = prog_manager.good_presses - ProgressManager.PRESS_PROG.FIFTH
		voice_player.stream = doubtful_voice_ending[num_press]
	
	voice_player.play(0.0)	

