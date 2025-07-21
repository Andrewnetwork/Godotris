class_name ClassicTetromino
extends Node2D

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
@export var type : TetrominoType 
@export var size : Vector2 = Vector2(10,10) 

func _create():
	var n_rows = tetromino_definition[type]["n_rows"]
	var n_cols = tetromino_definition[type]["n_cols"]
	var block_mask = tetromino_definition[type]["block_mask"]
			
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

	
func _init(type:TetrominoType=Tetromino.TetrominoType.values()[randi_range(0,6)], size= Vector2(25,25) ):
	self.type = type
	self.size = size

func _ready():
	_create()
	 
