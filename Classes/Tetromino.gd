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
				rect_shape.size = Vector2(cell_size.x-8, cell_size.y-8) 
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
				# TODO: fix magic number
				var collision_data = move_and_collide(Vector2(0, 800), true)
				if collision_data != null:
					move_flag = MoveType.STILL	 
					print("======")
					var parent_global_position = get_parent().global_position
					# Position of the collider relative to the game grid. 
					var collider_grid_position = collision_data.get_collider().global_position-parent_global_position
					var collision_grid_position = collision_data.get_position()-parent_global_position
					var collision_cell_position = collision_data.get_local_shape().position
					var collision_cell_col_row= collision_cell_position / cell_size + Vector2.ONE
					if collider_grid_position.y > 599:
						#TODO: fix this hacky solution to colliding with the world boundary.
						position.y = cell_size.y*(24-tetromino_definition[type].n_rows)+cell_size.y/2
					else:
						print("Parent global pos: "+str(parent_global_position))
						print("Collider grid position: "+str(collider_grid_position))
						print("Collision grid position: "+str(collision_grid_position))
						print("Collision cell position: "+str(collision_cell_position))
						print("Collision cell col_row: "+str(collision_cell_col_row))
						var collision_row = ceil(collision_grid_position.y/cell_size.y)
						print("Collides on row: "+str(collision_row))
						# Drop to the row above the collision. Position as many rows up as
						# it takes to accomidate the number of rows in the tetromino.
						#tetromino_definition[type].n_rows
						var new_cell_pos = collision_row-collision_cell_col_row.y
						print("New row: "+str(new_cell_pos))
						position.y = new_cell_pos*cell_size.y-cell_size.y/2
						print("New position: "+str(position.y))
					is_frozen = true
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
