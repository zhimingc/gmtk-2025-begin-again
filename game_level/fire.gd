class_name Fire extends ColorRect

@export var lights : Array[FireLight]
var fire_size : float = 0.8

func _ready() -> void:
	toggle_light(false)

func toggle_light(on : bool) -> void:
	if on:
		var fire_tween = create_tween()
		fire_tween.tween_property(self, "material:shader_parameter/ball_size", fire_size, 0.5)
		for light in lights:
			light.fade_in(1.0)
	else:
		material.set_shader_parameter("ball_size", 0.0)
		for light in lights:
			light.visible = false