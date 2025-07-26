class_name TetrominoManager
extends Node

var timer = 0
var player_tetromino = PlayerTetromino.new(Vector2(25,25))
var game_grid : Grid2D
var line_scanner : Area2D = Area2D.new()
var line_areas : Array[LineArea]
func _init(grid : Grid2D):
	game_grid = grid
	game_grid.add_item(player_tetromino, Vector2(0,8))
	create_line_areas()
	

func register_placed_tetromino(tetromino : PlayerTetromino):
	player_tetromino.place()
	line_clear_check(tetromino)

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
		
	
func line_clear_check(initiator: PlayerTetromino):
	## Checks for line clears
	await get_tree().physics_frame
	#for cell in initiator.cells:
		#print(ceil((cell.position.y+initiator.position.y) / game_grid.cell_size.y))
	#for line_area in initiator.bounding_box.get_overlapping_areas():
		#print(line_area.get_overlapping_bodies())
	#
	var scan_res = line_areas[23].get_overlapping_bodies()
	print("Line:  "+str(scan_res))
	
func _physics_process(delta: float):
	timer += delta
	if !player_tetromino.is_frozen:
		if int(ceil(timer)) % 2 == 0:
			timer = 0
			player_tetromino.move(PlayerTetromino.MoveType.DOWN)
	else:
		register_placed_tetromino(player_tetromino)

		# New piece to move. 
		player_tetromino = PlayerTetromino.new(Vector2(25,25))
		game_grid.add_item(player_tetromino, Vector2(0,8))
		
