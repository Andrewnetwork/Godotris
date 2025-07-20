class_name RandomColorSquare
extends Sprite2D


func _init(x_pos = 0, y_pos = 0, width : int = 1, height : int = 1):
	var new_texture := Image.create(width, height, false, Image.FORMAT_RGBA8)
	new_texture.fill(Color(1, 1, 1, 1))
	modulate = Color(randf(), randf(), randf(), 1)
	position = Vector2(x_pos, y_pos)
	texture = ImageTexture.create_from_image(new_texture)
	centered = false
	offset = Vector2(0, 0)


func fade_out(sec_duration=1):
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, sec_duration)
	tween.connect("finished", Callable(self, "_on_fade_complete"))

func fade_in(sec_duration=1):
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1, sec_duration)
	
func _on_fade_complete():
	modulate = Color(randf(), 1, randf(), 1)
	fade_out()
	
