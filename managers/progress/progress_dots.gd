class_name ProgressDots extends HBoxContainer

@export var empty_texture : Texture
@export var filled_texture : Texture
@export var star_done_texture : Texture

@onready var progress_dots : Array = get_children()

func _ready() -> void:
	set_progress_hud(0)

func set_progress_hud(stage : int) -> void:
	for i in progress_dots.size()-1:
		if i < stage:
			progress_dots[i].texture = filled_texture
		else:
			progress_dots[i].texture = empty_texture

func set_done() -> void:
	visible = false
	# progress_dots.back().texture = star_done_texture
