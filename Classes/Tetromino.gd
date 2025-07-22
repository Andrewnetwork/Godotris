class_name Tetromino
extends CharacterBody2D

enum MoveType {DOWN, LEFT, RIGHT, UP, STILL, DROP}
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
var cell_size : Vector2 
var move_flag : MoveType = MoveType.STILL
var is_frozen = false
var timer = 0
var shadow : Node2D = Node2D.new()
const hit_box_padding = 8.0

func _create_shadow():
	shadow.modulate.a = 0.5
	get_parent().add_child(shadow)
	
func _update_shadow():
	pass
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
				sprite.scale = cell_size
				sprite.position.x = column*cell_size.x
				sprite.position.y = row*cell_size.y
				# Add collsion shape. 
				var rect_shape = RectangleShape2D.new()
				# Make the collision shape a bit smaller so objects can be closer. 
				rect_shape.size = Vector2(cell_size.x-hit_box_padding, cell_size.y-hit_box_padding) 
				var collision_rect = CollisionShape2D.new()
				collision_rect.shape = rect_shape
				collision_rect.position = sprite.position
				# Add sprite and collision shape to the parent rigid body. 
				add_child(sprite)
				add_child(collision_rect)
				shadow.add_child(sprite.duplicate())
				
	
func _init(cell_size = Vector2(25.0,25.0), type:TetrominoType=Tetromino.TetrominoType.values()[randi_range(0,6)]):
	self.type = type
	self.cell_size = cell_size	
	_create()

func _ready():
	#_create_shadow()
	pass
	
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
	elif event.is_action_pressed("ui_up"):
		move(MoveType.UP)

func move(move_type: MoveType):
	# Disregard movement when dropping a piece. 
	if move_flag != MoveType.DROP:
		move_flag = move_type

func _physics_process(delta: float):
	timer += delta 
	if Input.is_physical_key_pressed(KEY_LEFT) && timer > 0.05:
		move_flag = MoveType.LEFT
		timer = 0
	elif Input.is_physical_key_pressed(KEY_RIGHT) && timer > 0.05:
		move_flag = MoveType.RIGHT
		timer = 0
	elif Input.is_physical_key_pressed(KEY_DOWN) && timer > 0.02:
		move_flag = MoveType.DOWN
		timer = 0
		
		
	if !is_frozen:
		match move_flag:
			MoveType.STILL:
				pass
			MoveType.DOWN:
				if move_and_collide(Vector2(0, cell_size.y), true) != null:
					is_frozen = true
					print(position)
				else:
					position.y += cell_size.y
				move_flag = MoveType.STILL	 
			MoveType.LEFT:
				if move_and_collide(Vector2(-cell_size.x, 0), true) == null:
					position.x -= cell_size.x
				move_flag = MoveType.STILL	 
			MoveType.RIGHT:
				if move_and_collide(Vector2(cell_size.x, 0), true) == null:
					position.x += cell_size.x
				move_flag = MoveType.STILL 
			MoveType.DROP:
				var collision_data = move_and_collide(Vector2(0, 800), true)
				if collision_data != null:
					# Get parent container of the tetromino--usually a grid. 
					var parent_global_position = get_parent().global_position
					# The position of the collision is reported in global coordinates. Subtract 
					# the parent's position to get the local position of the tetromino, i.e., 
					# the position of the collision within the grid(tetromino parent). 
					var collision_grid_position = collision_data.get_position()-parent_global_position
					# Get the position of the cell within the tetromino that reports the collision. 
					# This is the bottom left most cell that reports a collision. This position is 
					# in local coordinates, meaning it's relative to the tetromino's origin. 
					# We also must apply the tetromino's rotation to the position because apparently
					# it does not inherent the rotation of the parent for some strange reason?
					var hit_cell_position = collision_data.get_local_shape().position.rotated(rotation)
					# Add the tetromino's position to the hit cell position to get the position of
					# the hit cell within the grid, i.e., the grid's origin becomes the new origin.
					var hit_cell_grid_position = position+hit_cell_position
					# The y-distance between where the collision occured and the cell of the tetromino
					# that was hit. 
					var collision_y_distance = collision_grid_position.y-hit_cell_grid_position.y
					# Account for the hitbox padding. 
					# TODO: fix this hacky situation.
					var hit_box_padding_offset = hit_box_padding*2
					if collision_data.get_collider() is StaticBody2D:
						# Collision with world boundary. It doesn't have hitbox padding. 
						hit_box_padding_offset -= hit_box_padding
					var block_collision_y_distance = collision_y_distance - hit_box_padding_offset
					# Adjust the y-position.Stave off precision errors by making the move 
					# a multiple of the cell height.
					position.y += floor(block_collision_y_distance/cell_size.y)*cell_size.y
					# Set the flags to prevent further movement of this piece. 
					is_frozen = true
					move_flag = MoveType.STILL	 
				else:
					position.y += cell_size.y
			MoveType.UP:
				# TODO: fix out of bounds rotation
				rotate(deg_to_rad(90))
				#shadow.rotate(deg_to_rad(90))
				move_flag = MoveType.STILL 
	
	#if !is_frozen:
		##Now that we've finished updating the location, update the shadow.
		#var collision_data = move_and_collide(Vector2(0, 800), true) 
		#if collision_data != null:
			##print(collision_data.get_collider().position.y)
			##print(position.y)
			#shadow.position.y = collision_data.get_collider().position.y-cell_size.y*2
			#shadow.position.x = position.x
			##move_flag = MoveType.STILL
			##is_frozen = true
	#else:
		#if is_instance_valid(shadow):
			#shadow.queue_free()
