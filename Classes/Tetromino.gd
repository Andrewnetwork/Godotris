class_name Tetromino
extends CharacterBody2D

enum MoveType {DOWN, LEFT, RIGHT, STILL, DROP}
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

var type : TetrominoType
var size : Vector2 
var move_flag : MoveType = MoveType.STILL
var is_frozen = false

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
				# Make the collision shape a bit smaller so objects can be closer. 
				rect_shape.size = Vector2(size.x - 1, size.y - 0.05) 
				var collision_rect = CollisionShape2D.new()
				collision_rect.shape = rect_shape
				collision_rect.position = sprite.position
				# Add sprite and collision shape to the parent rigid body. 
				add_child(sprite)
				add_child(collision_rect)
				
	
func _init(size = Vector2(25.0,25.0), type:TetrominoType=Tetromino.TetrominoType.values()[randi_range(0,6)]):
	self.type = type
	self.size = size	
	_create()

# Character movement functions. 
func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_left"):
		move(MoveType.LEFT)
	elif event.is_action_pressed("ui_right"):
		move(MoveType.RIGHT)
	elif event.is_action_pressed("ui_down"):
		move(MoveType.DOWN)
	elif event.is_action_pressed("immediate_drop"):
		move(MoveType.DROP)

func move(move_type: MoveType):
	# Disregard movement when dropping a piece. 
	if move_flag != MoveType.DROP:
		move_flag = move_type

func _physics_process(delta: float):
	if !is_frozen:
		match move_flag:
			MoveType.STILL:
				pass
			MoveType.DOWN:
				if move_and_collide(Vector2(0, size.y)) != null:
					is_frozen = true
				move_flag = MoveType.STILL	 
			MoveType.LEFT:
				if move_and_collide(Vector2(-size.x, 0)) != null:
					pass
				move_flag = MoveType.STILL	 
			MoveType.RIGHT:
				if move_and_collide(Vector2(size.x, 0)) != null:
					pass
				move_flag = MoveType.STILL 
			MoveType.DROP:
				# TODO: fix this so we can teleport to the bottom. 
				if move_and_collide(Vector2(0, size.y)) != null:
					move_flag = MoveType.STILL	 
					is_frozen = true
