extends PointLight2D

@export var flicker_freq : Vector2 = Vector2(0.1, 0.25)
@export var flicker_scale : Vector2 = Vector2(-0.1, 0.1)
@export var flicker_energy : Vector2 = Vector2(-0.25, 1.0)

@onready var original_scale : float = texture_scale
@onready var original_energy : float = energy

var flicker_time : float
var cur_time : float
var flicker_amt : float
var target_scale : float
var target_energy : float
var prev_scale : float
var prev_energy : float

func _ready() -> void:
	new_flicker()

func new_flicker() -> void:
	prev_scale = texture_scale
	prev_energy = energy
	flicker_time = randf_range(flicker_freq.x, flicker_freq.y)
	cur_time = flicker_time
	target_scale = original_scale + randf_range(flicker_scale.x, flicker_scale.y)
	target_energy = original_energy + randf_range(flicker_energy.x, flicker_energy.y) 

func _process(delta: float) -> void:
	cur_time -= delta
	texture_scale = lerp(prev_scale, target_scale, 1.0 - max(0.0, cur_time/flicker_time))
	energy = lerp(prev_energy, target_energy, 1.0 - max(0.0, cur_time/flicker_time))
	if cur_time <= 0.0:
		new_flicker()

