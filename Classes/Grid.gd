@tool
class_name Grid
extends Node2D

@export var cell_size: Vector2 = Vector2(25, 25) : set = set_cell_size
@export var grid_size := Vector2i(20, 15) : set = set_grid_size
@export var grid_color: Color = Color(0.5, 0.5, 0.5) : set = set_grid_color
@export var background_color : Color = Color(1.0,1.0,1.0,0.0) : set = set_background_color

## Adds node to the grid and positions it at the given position. 
func add_item(grid_item: Node2D, cell_pos: Vector2i):
	grid_item.position = Vector2(cell_pos.x*cell_size.x+cell_size.x/2.0, cell_pos.y*cell_size.y-cell_size.y/2.0)
	add_child(grid_item)
# Setup
func _init_grid_boundaries():
	#[pos, normal]
	var boundary_positions = [[Vector2(0,grid_size.y*cell_size.y), Vector2.UP], 
		[Vector2(0,0), Vector2.DOWN], [Vector2(0,0), Vector2.RIGHT], 
		[Vector2(grid_size.x*cell_size.x,0), Vector2.LEFT]]
	
	for boundary_position in boundary_positions:
		var static_body = StaticBody2D.new()
		var world_boundary = CollisionShape2D.new()
		var world_boundary_shape = WorldBoundaryShape2D.new()
		static_body.position = boundary_position[0]
		world_boundary_shape.normal = boundary_position[1]
		world_boundary.shape = world_boundary_shape
		static_body.add_child(world_boundary)
		add_child(static_body)
# Getters and Setters
func set_cell_size(new_cell_size: Vector2):
	cell_size = new_cell_size
	queue_redraw()
func set_grid_size(new_grid_size: Vector2):
	grid_size = new_grid_size
	queue_redraw()
func set_grid_color(new_grid_color: Color):
	grid_color = new_grid_color
	queue_redraw()
func set_background_color(new_background_color: Color):
	background_color = new_background_color
	queue_redraw()
# Overloaded Functions
func _ready():
	if !Engine.is_editor_hint():
		_init_grid_boundaries()
func _draw():
	# Background
	draw_rect(Rect2(Vector2(0.0, 0.0), 
		Vector2(cell_size.x * grid_size.x, cell_size.y * grid_size.y) ),
			background_color)
	# Vertical lines
	for x in range(grid_size.x + 1):
		var start = Vector2(x * cell_size.x, 0)
		var end = Vector2(x * cell_size.x, grid_size.y * cell_size.y)
		draw_line(start, end, grid_color)
	# Horizontal lines
	for y in range(grid_size.y + 1):
		var start = Vector2(0.0, y * cell_size.y)
		var end = Vector2(grid_size.x * cell_size.x, y * cell_size.y)
		draw_line(start, end, grid_color)
