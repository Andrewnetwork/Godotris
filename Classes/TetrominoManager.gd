class_name TetrominoManager
extends Node


#==== UI Elements =====
## Game grid where pieces are placed and moved. 
@export_group("UI Elements")
@export var game_grid: Grid
@export var round_text: RichTextLabel

@export_group("Gameplay Settings")
## Number of rounds in the game.
@export var rounds := 10
## How much the drop speed is increased per round. 
@export var round_speed := 0.25
## How many line clears are required to advance to the next round.
@export var round_clears := 10

@export_subgroup("Movment Settings")
## Determines how fast a piece moves when the user holds down a control key.
## Reasonable values seem to be around 0.1.
@export var key_down_speed := 0.1

#==== Game Settings ====
@export_group("Settings")
## Current round.
@export var current_round := 1



## The tetromino actively being moved by the player. 
var player_tetromino: PlayerTetromino
## Areas that detect pieces occupying lines. One for every line.
var line_areas: Array[LineArea]
var n_lines_cleared := 0
var round_tick_time := 1.0
var round_tick_timer := 0.0


func piece_placed(rows_affected: Array[int]):
	await get_tree().physics_frame
	line_clear_check(rows_affected)
	# New piece to move. 
	create_new_player_tetromino()
func move_down_rows(starting_row: int, n_rows: int):
	print("Moving down: ",starting_row,"  ",n_rows)
	for i_row in range(starting_row):
		var cells_in_line = line_areas[i_row].get_overlapping_bodies()
		for cell in cells_in_line:
			var movement_tween := cell.create_tween()
			movement_tween.tween_property(cell, "position", cell.position+Vector2(0,game_grid.cell_size.y*n_rows), 0.1)
			movement_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			#cell.position.y += game_grid.cell_size.y*n_rows
			
## Checks the row numbers in [param check_rows] for line clears
func line_clear_check(check_rows: Array[int]):
	await get_tree().physics_frame
	var n_clears = 0
	for row_idx in check_rows:
		var cells_in_line = line_areas[row_idx].get_overlapping_bodies()
		if len(cells_in_line) == game_grid.grid_size.x:
			for cell in cells_in_line:
				cell.queue_free()
			n_clears += 1
	

	if n_clears > 0:
		n_lines_cleared += n_clears
		move_down_rows(check_rows.max(), n_clears)
		# Advance to next round.
		if n_lines_cleared >= round_clears*current_round:
			current_round += 1
			start_round()
# Round Logic
func round_tick():
	player_tetromino.move(PlayerTetromino.MoveType.DOWN)
func start_round():
	round_tick_time = (1+rounds-current_round)*round_speed
	print(round_tick_time)
	round_text.text = str(current_round)
# Setup
func create_new_player_tetromino():
	player_tetromino = PlayerTetromino.new(game_grid)
	player_tetromino.connect("placed", piece_placed)
	game_grid.add_item(player_tetromino, Vector2(0,8))
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
func _ready():
	create_new_player_tetromino()
	create_line_areas()
	# Start round.
	start_round()
	
func _physics_process(delta: float) -> void:
	round_tick_timer += delta

	if round_tick_timer >= round_tick_time:
		round_tick()
		round_tick_timer = 0
		
