class_name TetrominoCellShape
extends CollisionShape2D

var sprite : Sprite2D

func duplicate_at_offset(offset: Vector2):
	var dupe = duplicate()
	dupe.position += offset
func new():
	pass
func _init(color: Color, cell_size : Vector2, cell_position: Vector2, hit_box_padding: float) -> void:
	# Create a 1x1 image and fill it with the color of the tetromino.
	var img = Image.create(1,1,false, Image.FORMAT_RGBA8)
	img.fill(color)
	# Create a sprite and texture it with the above image. 
	sprite = Sprite2D.new()
	sprite.material = ShaderMaterial.new()
	sprite.material.shader = load("res://Shaders/tetrino_cell.gdshader")
	sprite.texture = ImageTexture.create_from_image(img)
	sprite.scale = cell_size
 	
	# Add collsion shape. 
	var rect_shape = RectangleShape2D.new()
	# Make the collision shape a bit smaller so objects can be closer. 
	rect_shape.size = Vector2(cell_size.x-hit_box_padding, cell_size.y-hit_box_padding) 

	shape = rect_shape
	position = cell_position
	add_child(sprite)
