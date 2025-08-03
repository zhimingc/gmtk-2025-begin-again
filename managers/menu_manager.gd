class_name MenuManager extends Node

@export var menu_audio : Array[AudioStream]

@onready var progress_dots = %ProgressDots
@onready var mindful_vis : MindfulVisualizer = %MindfulVisualizer
@onready var start_prompt = %StartPrompt
@onready var again_prompt = %BeginAgain
@onready var main_menu = %MainMenu
@onready var game_view : PhantomCamera2D = %GameView
@onready var menu_bg = %MenuBG
@onready var menu_player : AudioStreamPlayer = $MenuAudio

var in_menu : bool = true
var menu_bg_color : Color

func _ready() -> void:
	menu_bg_color = menu_bg.modulate 
	progress_dots.modulate = Color.TRANSPARENT
	start_prompt.modulate = Color.TRANSPARENT
	again_prompt.modulate = Color.TRANSPARENT
	mindful_vis.toggle_main_menu_view(true)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("mindful_input"):
		if in_menu:
			enter_game()

func enter_menu() -> void:
	var tween_timer = 1.0
	var modulate_tween = create_tween()
	modulate_tween.tween_property(main_menu, "modulate", Color.WHITE, tween_timer)
	modulate_tween.parallel().tween_property(menu_bg, "modulate", menu_bg_color, tween_timer)
	progress_dots.modulate = Color.TRANSPARENT
	start_prompt.modulate = Color.TRANSPARENT
	again_prompt.modulate = Color.TRANSPARENT
	mindful_vis.toggle_main_menu_view(true)
	game_view.priority = 0

func enter_game() -> void:
	var enter_game_tween = create_tween()
	var tween_timer = 4.0
	# turn off lights
	menu_player.stream = menu_audio[0]
	menu_player.play(0.0)
	main_menu.modulate = Color.TRANSPARENT
	enter_game_tween.tween_callback(func(): menu_bg.modulate = Color.TRANSPARENT)
	enter_game_tween.tween_interval(2.0)
	# light candle
	enter_game_tween.tween_callback(func(): 
		menu_player.stream = menu_audio[1]
		menu_player.play(0.0)
		%Fire.toggle_light(true))
	enter_game_tween.tween_interval(2.0)
	# pan camera
	enter_game_tween.tween_callback(func(): game_view.priority = 2) 
	enter_game_tween.tween_property(progress_dots, "modulate", Color.WHITE, tween_timer)
	enter_game_tween.parallel().tween_property(start_prompt, "modulate", Color.WHITE, tween_timer)
	enter_game_tween.tween_callback(func():mindful_vis.toggle_main_menu_view(false))
	enter_game_tween.tween_callback(func(): %MindfulManager.set_mindful_state(MindfulManager.MINDFUL_STATE.IDLE))
	in_menu = false
