class_name VoiceManager extends Node

@export var game_start_voice : AudioStream
@export var guiding_bad_press_voices : Array[AudioStream]
@export var guiding_random_voices : Array[AudioStream]
@export var doubtful_voice_ending : Array[AudioStream]
@export var doubtful_random_voices : Array[AudioStream]

@onready var mindful_manager : MindfulManager = %MindfulManager
@onready var prog_manager : ProgressManager = %ProgressManager
@onready var voice_player : AudioStreamPlayer = $VoicePlayer
@onready var guiding_vignette : Sprite2D = %GuidingVignette
@onready var doubting_vignette : Sprite2D = %DoubtingVignette

var original_vignette_scale : Vector2
var is_guiding_voice_talking : bool = false
var miss_odds : int = 20
var good_odds : int = 40
var guiding_voice_bag : Array[AudioStream]
var doubtful_voice_bag : Array[AudioStream]
var spectrum_analyzer
var bus_idx = AudioServer.get_bus_index("Voices") 
var vignette_fade_tween : Tween

func _ready() -> void:
	hide_vignettes()
	mindful_manager.connect("broadcast_game_starting", on_game_running)
	mindful_manager.connect("broadcast_bad_press", on_bad_press)
	mindful_manager.connect("broadcast_good_press", on_good_press)
	spectrum_analyzer = AudioServer.get_bus_effect_instance(bus_idx, 0)
	original_vignette_scale = guiding_vignette.scale

func _process(_delta: float) -> void:
	if voice_player.playing:
		var volume_magnitude = spectrum_analyzer.get_magnitude_for_frequency_range(0, 20000).length()
		var scale_mapped = remap(volume_magnitude, 0.0, 0.1, 1.1, 1.0) * Vector2.ONE
		if is_guiding_voice_talking:
			guiding_vignette.scale = scale_mapped
		else:
			doubting_vignette.scale = scale_mapped
	elif !vignette_fade_tween or !vignette_fade_tween.is_running():
		fade_vignettes()

func on_game_running() -> void:
	start_guiding_voice(game_start_voice)
	
func on_bad_press() -> void:
	start_guiding_voice(guiding_bad_press_voices.pick_random())
	if prog_manager.last_stage == ProgressManager.PRESS_PROG.FIFTH:
		start_doubting_voice(doubtful_voice_ending[0])

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
		if voice_roll < miss_odds:
			return
		elif voice_roll < good_odds:
			start_guiding_voice(get_random_guiding_voice())
		else:
			start_doubting_voice(get_random_doubtful_voice())
		if prog_manager.last_stage == ProgressManager.PRESS_PROG.FIFTH:
			var num_press = prog_manager.good_presses - ProgressManager.PRESS_PROG.FIFTH
			start_doubting_voice(doubtful_voice_ending[num_press])

func start_guiding_voice(voice_stream : AudioStream) -> void:
	voice_player.stream = voice_stream
	is_guiding_voice_talking = true
	hide_vignettes()
	var fade_tween = create_tween()
	fade_tween.tween_property(guiding_vignette, "modulate", Color.WHITE, 0.25)
	voice_player.play(0.0)

func start_doubting_voice(voice_stream : AudioStream) -> void:
	voice_player.stream = voice_stream
	is_guiding_voice_talking = false
	hide_vignettes()
	var fade_tween = create_tween()
	fade_tween.tween_property(doubting_vignette, "modulate", Color.WHITE, 0.25)
	voice_player.play(0.0)

func fade_vignettes() -> void:
	vignette_fade_tween = create_tween()
	vignette_fade_tween.tween_property(doubting_vignette, "modulate", Color.TRANSPARENT, 0.25)
	vignette_fade_tween.parallel().tween_property(guiding_vignette, "modulate", Color.TRANSPARENT, 0.25)

func hide_vignettes() -> void:
	doubting_vignette.modulate = Color.TRANSPARENT
	doubting_vignette.scale = original_vignette_scale
	guiding_vignette.modulate = Color.TRANSPARENT
	guiding_vignette.scale = original_vignette_scale