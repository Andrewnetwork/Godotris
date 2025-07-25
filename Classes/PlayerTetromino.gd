class_name PlayerTetromino
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
var cells : Array[TetrominoCellShape]
const hit_box_padding = 0.05
var bounding_box : Area2D = Area2D.new()
var rotation_collisions : Array[Node2D]
var grid: Grid2D

func _stage_shadow():
	shadow.modulate.a = 0.5
	grid.add_child(shadow)	
func _update_shadow():
	var drop_pos = get_drop_pos()
	if drop_pos != Vector2.ZERO:
		#TODO figure out error in x position
		shadow.position.y = get_drop_pos().y+position.y
		shadow.position.x = position.x 
		
	if shadow.get_parent() == null:
		# Shadow has not been added to the scene tree yet. 
		_stage_shadow()
func _create():
	# Data defining the tetromino.
	var n_rows = tetromino_definition[type]["n_rows"]
	var n_cols = tetromino_definition[type]["n_cols"]
	var block_mask = tetromino_definition[type]["block_mask"]
	
	# A bounding box area for the whole tetromino. 
	var bounding_box_rect = RectangleShape2D.new()
	bounding_box_rect.set_size(Vector2(cell_size.x*n_cols-hit_box_padding, cell_size.y*n_rows-hit_box_padding))
	var bounding_box_shape = CollisionShape2D.new()
	bounding_box_shape.shape = bounding_box_rect
	bounding_box_shape.position = (bounding_box_rect.size/2)-Vector2.ONE*(hit_box_padding*3/2)
	bounding_box.add_child(bounding_box_shape)
	add_child(bounding_box)

	for row in range(n_rows):
		for column in range(n_cols):
			var index = row*n_cols + column
			if block_mask[index]:
				var nt = TetrominoCellShape.new(tetromino_definition[type]["color"], cell_size, 
					Vector2(column*cell_size.x, row*cell_size.y), hit_box_padding)
				add_child(nt)
				cells.append(nt)
				shadow.add_child(nt.duplicate(false))
func _init(game_grid: Grid2D, cell_size_cr = Vector2(25.0,25.0), tetromino_type:TetrominoType=PlayerTetromino.TetrominoType.values()[randi_range(0,6)]):
	type = tetromino_type
	cell_size = cell_size_cr
	bounding_box.monitoring = true
	grid = game_grid
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
	elif event.is_action_pressed("ui_up"):
		move(MoveType.UP)
func move(move_type: MoveType):
	# Disregard movement when dropping a piece. 
	if move_flag != MoveType.DROP:
		move_flag = move_type	
func get_drop_pos():
	#TODO fix magic number 1000. Need to figure out way of getting parent's height.
	var collision_data = move_and_collide(Vector2(0, 1000), true)
	if collision_data != null:
		# Get parent container of the tetromino--usually a grid. 
		var parent_global_position = grid.global_position
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
		var collision_distance = collision_grid_position-hit_cell_grid_position
		# Account for the hitbox padding. 
		# TODO: fix this hacky situation.
		var hit_box_padding_offset = hit_box_padding*2
		if collision_data.get_collider() is StaticBody2D:
			# Collision with world boundary. It doesn't have hitbox padding. 
			hit_box_padding_offset -= hit_box_padding
		var block_collision_distance = collision_distance - Vector2(hit_box_padding_offset, hit_box_padding_offset)
		# Adjust the y-position.Stave off precision errors by making the move 
		# a multiple of the cell height.
		return floor(block_collision_distance/cell_size)*cell_size
	else:
		#push_error("No collision when updating shadow! There should always be a collision.")
		print("error")
		return Vector2.ZERO
func safe_rotate():
	# Rotate the bounding box to test for rotation collisions. 
	bounding_box.rotate(deg_to_rad(90))
	# Wait for all physics calculations to be completed before checking
	# for collisions with bounding box. 
	await get_tree().physics_frame
	# Get all of the bodies colliding with the bounding box. 
	rotation_collisions = bounding_box.get_overlapping_bodies()
	# Remove the tetromino, which is within the bounding box. 
	rotation_collisions.erase(self)
	# If there are no collisions, rotate the tetromino and its drop shadow. 
	if len(rotation_collisions) == 0:
		rotate(deg_to_rad(90))
		shadow.rotate(deg_to_rad(90))
	# Undo the collision check rotation of the bounding box. 
	bounding_box.rotate(deg_to_rad(-90))	
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
				position.y += get_drop_pos().y
				# Set the flags to prevent further movement of this piece. 
				is_frozen = true
				move_flag = MoveType.STILL	 
			MoveType.UP:
				safe_rotate()
				move_flag = MoveType.STILL 
	#Now that we've finished updating the location, update the shadow.
	if !is_frozen:
		_update_shadow()
	else:
		# If this tetromino has been frozen in place, queue its shadow for deletion.
		if is_instance_valid(shadow):
			shadow.queue_free()
func dissolve():
	## Dissolve the player tetromino into individual static body cells.
	for cell in cells:
		var rigid_cell = TetrominoCellBody.new(grid)
		var cell_duplicate = cell.duplicate(false)
		cell_duplicate.position = position + cell_duplicate.position.rotated(rotation)
		rigid_cell.add_child(cell_duplicate)
		rigid_cell.freeze = true
		rigid_cell.freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
		grid.add_child(rigid_cell)
	grid.remove_child(self)

	queue_free()
func place(place_position : Vector2 = self.position) -> Array[int]:
	## Place the tetromino, dissolve the character body, and return the index of the rows affected 
	## by the placement. 
	var rows_affected : Array[int] = []
	for cell in cells:
		var row_idx =  int(ceil((position.y+cell.position.rotated(rotation).y) / cell_size.y))-1
		if not rows_affected.has(row_idx):
			rows_affected.append(row_idx)
	position = place_position
	is_frozen = true 
	dissolve()
	return rows_affected
