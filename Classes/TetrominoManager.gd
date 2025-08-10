class_name TetrominoManager
extends Node

@export_group("UI Elements")
## Game grid where pieces are placed and moved. 
@export var game_grid: Grid
## Rich text label used to display the current round.
@export var held_piece: Node2D
@export var round_text: RichTextLabel
@export var game_over_screen : Node2D
@export var background_music_player : AudioStreamPlayer
@export var animation_player: AnimationPlayer

@export_group("Gameplay Settings")
## Number of rounds in the game.
@export var rounds := 10
## How many line clears are required to advance to the next round.
@export var round_clears := 10
## Determines the speed of each round. The maximum domain should match the number of rounds in the game.
## The minimum value is the fastest speed.
@export var round_speed_curve : Curve = preload("res://Misc/default_round_speed_curve.tres")


@export_subgroup("Movment Settings")
## Determines how fast a piece moves when the user holds down a control key.
## Reasonable values seem to be around 0.1.
@export var key_down_speed := 0.1
## The ammount of time in seconds before a drop is forced while moving a piece.
@export var drop_delay := 2

#=== Game Settings
@export_group("General Settings")
## Current round. The initial value represents at what round the game begins.
@export var current_round := 1

#=== Sounds
@export_group("Sound Effects")
@export var error_sound: AudioStream = preload("res://Sound/error.wav")
@export var line_clear_sound: AudioStream = preload("res://Sound/clear.mp3")
@export var clear_1_sound: AudioStream = preload("res://Sound/clear_1.mp3")
@export var clear_2_sound: AudioStream = preload("res://Sound/clear_2.mp3")
@export var clear_3_sound: AudioStream = preload("res://Sound/clear_3.mp3")
@export var clear_4_sound: AudioStream = preload("res://Sound/clear_4.mp3")
@export var hold_click: AudioStream = preload("res://Sound/hold_click.mp3")


# Effect player
var sfx_player := AudioStreamPlayer.new()
var sfx_player2 := AudioStreamPlayer.new()
## Areas that detect pieces occupying lines. One for every line.
var line_areas: Array[Area2D]
#=== Internal counters.
var n_lines_cleared := 0
var round_tick_time := 1.0
var round_tick_timer := 0.0
#=== Game States
var held_tetromino = null
var held_this_turn = false
## The tetromino actively being moved by the player. 
var player_tetromino: PlayerTetromino


func play_sound(sfx: AudioStream):
	if !sfx_player.playing:
		sfx_player.stream = sfx
		sfx_player.play()
	elif !sfx_player2.playing:
		sfx_player2.stream = sfx
		sfx_player2.play()
	else:
		push_error("No available audio stream players to play TetrominoManager SFX.")
	
func _on_invalid_placement():
	game_over_screen.visible = true
	background_music_player.stop()
	var game_over_sound = preload("res://Sound/game_over.wav")
	background_music_player.stream = game_over_sound
	background_music_player.play()
	# Stops the game loop.
	set_physics_process(false)
	player_tetromino.queue_free()
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
		# Play general line clear sound.
		play_sound(line_clear_sound)
		# Add additional sound effect indicating the number of clears.
		if n_clears == 1:
			play_sound(clear_1_sound)
		elif n_clears == 2:
			play_sound(clear_2_sound)
		elif n_clears == 3:
			play_sound(clear_3_sound)
		elif n_clears == 4:
			play_sound(clear_4_sound)
			
		move_down_rows(check_rows.max(), n_clears)
		# Advance to next round.
		if n_lines_cleared >= round_clears*current_round:
			current_round += 1
			start_round()
# Round Logic
func round_tick():
	player_tetromino.move(PlayerTetromino.MoveType.TICK_DOWN)
func start_round():
	round_tick_time = round_speed_curve.sample(current_round)
	round_text.text = str(current_round)
	background_music_player.pitch_scale += 0.01
func _physics_process(delta: float) -> void:
	round_tick_timer += delta

	if round_tick_timer >= round_tick_time:
		round_tick()
		round_tick_timer = 0
# Setup
func _ready():
	create_new_player_tetromino()
	create_line_areas()
	sfx_player.max_polyphony = 5
	add_child(sfx_player)
	add_child(sfx_player2)
	# Start round.
	start_round()
func create_new_player_tetromino(tetromino_type: PlayerTetromino.TetrominoType=PlayerTetromino.TetrominoType.values()[randi_range(0,6)]):
	player_tetromino = PlayerTetromino.new(game_grid, tetromino_type)
	player_tetromino.key_down_speed = key_down_speed
	player_tetromino.drop_delay = drop_delay
	player_tetromino.connect("placed", piece_placed)
	player_tetromino.connect("invalid_placement", _on_invalid_placement)
	held_this_turn = false
	@warning_ignore("integer_division")
	game_grid.add_item(player_tetromino, Vector2i(floor(game_grid.grid_size.x/2),0))
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
		var line_area = Area2D.new()
		line_area.add_child(line_rect_cshape)
		line_areas.append(line_area)
		game_grid.add_child(line_area)
# Control
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("hold"):
		if !held_this_turn:
			var current_tetromino_type = player_tetromino.type
			player_tetromino.destroy()
			if held_tetromino == null:
				held_tetromino = current_tetromino_type
				create_new_player_tetromino()
			else:
				create_new_player_tetromino(held_tetromino)
				held_tetromino = current_tetromino_type
			display_new_hold()
			held_this_turn=true
		else:
			# Can only store in or swap with hold once per turn.
			animation_player.play("thumb_down_shake_hold")
			play_sound(error_sound)
		
# UI
func display_new_hold():
	#TODO: make more efficient and fix off centered positioning. 
	play_sound(hold_click)
	for child in held_piece.get_children():
		if child is Node2D:
			held_piece.remove_child(child)
			break
	var flat_hold_image = PlayerTetromino.new(game_grid, held_tetromino).flattened
	flat_hold_image.scale = Vector2(0.4,0.4)
	held_piece.add_child(flat_hold_image)
func _on_play_again_pressed() -> void:
	get_tree().reload_current_scene()
