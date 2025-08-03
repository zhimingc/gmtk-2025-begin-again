class_name VoiceManager extends Node

@export var game_start_voice : AudioStream
@export var guiding_bad_press_voices : Array[AudioStream]
@export var guiding_random_voices : Array[AudioStream]
@export var doubtful_voice_ending : Array[AudioStream]
@export var doubtful_random_voices : Array[AudioStream]

@onready var mindful_manager : MindfulManager = %MindfulManager
@onready var prog_manager : ProgressManager = %ProgressManager
@onready var voice_player : AudioStreamPlayer = $VoicePlayer

var good_odds : int = 20
var guiding_voice_bag : Array[AudioStream]
var doubtful_voice_bag : Array[AudioStream]

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

func get_random_guiding_voice() -> AudioStream:
	if guiding_voice_bag.is_empty():
		guiding_voice_bag = guiding_random_voices.duplicate()
		guiding_voice_bag.shuffle()
	
	return guiding_voice_bag.pop_front()

func get_random_doubtful_voice() -> AudioStream:
	if doubtful_voice_bag.is_empty():
		doubtful_voice_bag = doubtful_random_voices.duplicate()
		doubtful_voice_bag.shuffle()
	
	return doubtful_voice_bag.pop_front()

func on_good_press() -> void:
	if prog_manager.last_stage == ProgressManager.PRESS_PROG.DONE:
		# play some ending voice here, if i get to it
		return
	
	if prog_manager.last_stage >= ProgressManager.PRESS_PROG.FIRST:
		var voice_roll = randi_range(0,100)
		if voice_roll < good_odds:
			voice_player.stream = get_random_guiding_voice()
		else:
			voice_player.stream = get_random_doubtful_voice()
		if prog_manager.last_stage == ProgressManager.PRESS_PROG.FIFTH:
			var num_press = prog_manager.good_presses - ProgressManager.PRESS_PROG.FIFTH
			voice_player.stream = doubtful_voice_ending[num_press]
		
		voice_player.play(0.0)	

