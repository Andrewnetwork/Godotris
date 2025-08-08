class_name TetrominoManager
extends Node

var timer = 0
## Game grid where pieces are placed and moved. 
var game_grid : Grid
## The tetromino actively being moved by the player. 
var player_tetromino : PlayerTetromino
## Areas that detect pieces occupying lines. One for every line.
var line_areas : Array[LineArea]

func register_placed_tetromino(tetromino : PlayerTetromino):
	line_clear_check(tetromino.place())
func move_down_rows(starting_row: int, n_rows: int):
	print("Moving down: ",starting_row,"  ",n_rows)
	for i_row in range(starting_row):
		var cells_in_line = line_areas[i_row].get_overlapping_bodies()
		for cell in cells_in_line:
			var movement_tween := cell.create_tween()
			movement_tween.tween_property(cell, "position", cell.position+Vector2(0,game_grid.cell_size.y*n_rows), 0.25)
			movement_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
			#cell.position.y += game_grid.cell_size.y*n_rows
			
## Checks the row numbers in [param check_rows] for line clears
func line_clear_check(check_rows: Array[int]):
	await get_tree().physics_frame
	
	var n_clears = 0
	for row_idx in check_rows:
		var cells_in_line = line_areas[row_idx].get_overlapping_bodies()
		#print(row_idx,"  ",len(cells_in_line))
		#print(cells_in_line)
		if len(cells_in_line) == game_grid.grid_size.x:
			for cell in cells_in_line:
				cell.queue_free()
			n_clears += 1
			
	if n_clears > 0:
		move_down_rows(check_rows.max(), n_clears)
# Setup
func create_line_areas():
	var line_rect = RectangleShape2D.new()
	line_rect.set_size(Vector2(game_grid.cell_size.x*game_grid.grid_size.x-player_tetromino.hit_box_padding*2, 
		game_grid.cell_size.y-player_tetromino.hit_box_padding*2))
			
	for row in range(game_grid.grid_size.y):
		# Create collision shape for line area.
		var line_rect_cshape = CollisionShape2D.new()
		line_rect_cshape.shape = line_rect
		line_rect_cshape.position = (line_rect.size/2)+Vector2.ONE*(player_tetromino.hit_box_padding)+Vector2(0, game_grid.cell_size.y * row)
		# Create a new line area for the row and add it to the game grid.
		var line_area = LineArea.new()
		line_area.add_child(line_rect_cshape)
		line_areas.append(line_area)
		game_grid.add_child(line_area)
# Overloaded Functions
func _init(grid : Grid):
	game_grid = grid
	player_tetromino = PlayerTetromino.new(game_grid)
	game_grid.add_item(player_tetromino, Vector2(0,8))
	create_line_areas()
func _physics_process(delta: float):
	timer += delta
	if !player_tetromino.is_frozen:
		if int(ceil(timer)) % 2 == 0:
			timer = 0
			player_tetromino.move(PlayerTetromino.MoveType.DOWN)
	else:
		register_placed_tetromino(player_tetromino)

		# New piece to move. 
		player_tetromino = PlayerTetromino.new(game_grid)
		game_grid.add_item(player_tetromino, Vector2(0,8))
		
