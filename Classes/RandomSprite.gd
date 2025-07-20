class_name RandomSprite
extends Sprite2D

@export var height = 10 : set = _set_height
@export var width = 10 : set = _set_width
@export var color = Color.WHITE : set = _set_color
@export var density = 0.5 : set = _set_density

func _init():
	centered = false
	offset = Vector2(0, 0)
	
func _ready():
	texture = _create_texture()

func _set_height(val):
	height = val
func _set_width(val):
	width = val
func _set_color(val):
	color = val
func _set_density(val):
	density = val
	
func _create_texture():
	var sprite_texture = Image.create(width, height, false, Image.FORMAT_RGBA8)
	for x in range(height):
		for y in range(width):
			if randf() > density:
				sprite_texture.set_pixel(x,y, color)
	return ImageTexture.create_from_image(sprite_texture)
			
	
	
	
	
