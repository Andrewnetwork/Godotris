class_name TetrominoManager
extends Node

var timer = 0
var game_grid : Grid2D
var player_tetromino : PlayerTetromino
var line_scanner : Area2D = Area2D.new()
var line_areas : Array[LineArea]
func _init(grid : Grid2D):
	game_grid = grid
	player_tetromino = PlayerTetromino.new(game_grid, Vector2(25,25))
	game_grid.add_item(player_tetromino, Vector2(0,8))
	create_line_areas()
	

func register_placed_tetromino(tetromino : PlayerTetromino):
	line_clear_check(player_tetromino.place())

func turn_on_physics():
	for child in game_grid.get_children():
		if child is RigidBody2D:
			child.freeze = false
			
func create_line_areas():
	var line_rect = RectangleShape2D.new()
	line_rect.set_size(Vector2(game_grid.cell_size.x*game_grid.grid_size.x-player_tetromino.hit_box_padding*2, 
		game_grid.cell_size.y-player_tetromino.hit_box_padding*2))
			
	for row in range(game_grid.grid_size.y):
		var line_rect_cshape = CollisionShape2D.new()
		line_rect_cshape.shape = line_rect
		line_rect_cshape.position = (line_rect.size/2)+Vector2.ONE*(player_tetromino.hit_box_padding)+Vector2(0, game_grid.cell_size.y * row)
		var line_area = LineArea.new()
		line_area.add_child(line_rect_cshape)
		line_areas.append(line_area)
		game_grid.add_child(line_area)
		
	
func line_clear_check(check_rows: Array[int]):
	## Checks for line clears
	await get_tree().physics_frame
	#for cell in initiator.cells:
		#print(ceil((cell.position.y+initiator.position.y) / game_grid.cell_size.y))
	for row_idx in check_rows:
		var cells_in_line = line_areas[row_idx].get_overlapping_bodies()
		if len(cells_in_line) == game_grid.grid_size.x:
			for cell in cells_in_line:
				cell.queue_free()
				turn_on_physics()
			
	
	
func _physics_process(delta: float):
	timer += delta
	if !player_tetromino.is_frozen:
		if int(ceil(timer)) % 2 == 0:
			timer = 0
			player_tetromino.move(PlayerTetromino.MoveType.DOWN)
	else:
		register_placed_tetromino(player_tetromino)

		# New piece to move. 
		player_tetromino = PlayerTetromino.new(game_grid, Vector2(25,25))
		game_grid.add_item(player_tetromino, Vector2(0,8))
		
