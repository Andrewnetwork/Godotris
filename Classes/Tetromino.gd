@tool
class_name Tetromino
extends RigidBody2D

enum TetrominoType {I, O, T, S, Z, J, L}
const tetromino_definition = {
	TetrominoType.I: {"block_mask":[1,1,1,1], "n_rows":1, "n_cols":4, "color": Color.CYAN},
	TetrominoType.O: {"block_mask":[1,1,1,1], "n_rows":2, "n_cols":2, "color": Color.YELLOW},
	TetrominoType.J: {"block_mask":[1,0,0,1,1,1], "n_rows":2, "n_cols":3, "color": Color.BLUE},
	TetrominoType.S: {"block_mask":[0,1,1,1,1,0], "n_rows":2, "n_cols":3, "color": Color.GREEN},
	TetrominoType.T: {"block_mask":[0,1,0,1,1,1], "n_rows":2, "n_cols":3, "color": Color.MAGENTA},
	TetrominoType.Z: {"block_mask":[1,1,0,0,1,1], "n_rows":2, "n_cols":3, "color": Color.RED},
	TetrominoType.L: {"block_mask":[0,0,1,1,1,1], "n_rows":2, "n_cols":3, "color": Color.ORANGE}
}
@export var type : TetrominoType : set = _type_changed
@export var size : Vector2 = Vector2(10,10) : set = _size_changed

func _type_changed(value: TetrominoType):
	type = value
	_create()
func _size_changed(value: Vector2):
	size = value
	_create()
	
func _create():
	var n_rows = tetromino_definition[type]["n_rows"]
	var n_cols = tetromino_definition[type]["n_cols"]
	var block_mask = tetromino_definition[type]["block_mask"]
	
	# Clean up prior pieces.
	if get_children().size() > 0:
		for child in get_children():
			remove_child(child)
			child.queue_free()
			
	for row in range(n_rows):
		for column in range(n_cols):
			if block_mask[row*n_cols + column]:
				# Create a 1x1 image and fill it with the color of the tetromino.
				var img = Image.create(1,1,false, Image.FORMAT_RGBA8)
				img.fill(tetromino_definition[type]["color"])
				# Create a sprite and texture it with the above image. 
				var sprite = Sprite2D.new()
				sprite.material = ShaderMaterial.new()
				sprite.material.shader = load("res://Shaders/tetrino_cell.gdshader")
				sprite.texture = ImageTexture.create_from_image(img)
				sprite.scale = size
				sprite.position.x = column*size.x
				sprite.position.y = row*size.y
				# Add collsion shape. 
				var rect_shape = RectangleShape2D.new()
				rect_shape.size = size
				var collision_rect = CollisionShape2D.new()
				collision_rect.shape = rect_shape
				collision_rect.position = sprite.position
				# Add sprite and collision shape to the parent rigid body. 
				add_child(sprite)
				add_child(collision_rect)

func get_shape() -> Polygon2D:
	## Creates a polygon with the verticies of the tetromino's blocks.
	var points : Array[Vector2] = []
	for child in get_children():
		if child is Sprite2D:
			child.position
	return null
	### Used TODO  
func _collision_detected(body: Node):
	#set_deferred("freeze", true)
	pass
	
func _init(type:TetrominoType=TetrominoType.I):
	self.type = type
	
func _ready():
	contact_monitor = true
	max_contacts_reported = 1
	freeze_mode = RigidBody2D.FreezeMode.FREEZE_MODE_STATIC
	body_entered.connect(_collision_detected)
	_create()
		
func _process(delta: float):
	pass
	## Garbage collection
	#var window_size = get_viewport().get_visible_rect().size
	#if position.x < -300 || position.y < -300 || position.x > window_size.x+300 || position.y > window_size.y + 300:
		#queue_free()
	
	
	 
