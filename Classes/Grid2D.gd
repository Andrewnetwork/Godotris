@tool
class_name Grid2D
extends Node2D

@export var cell_size: Vector2 = Vector2(25, 25)
@export var grid_size: Vector2 = Vector2(20, 15)
@export var grid_color: Color = Color(0.5, 0.5, 0.5)
@export var background_color : Color = Color(1.0,1.0,1.0,0.0)
var grid_items : Array[Node2D]
var grid_boundaries : Array[StaticBody2D]

func _ready():
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
		grid_boundaries.append(static_body)
		add_child(static_body)
func add_item(grid_item: Node2D, center_cell: Vector2):
	grid_item.position = Vector2(center_cell.y*cell_size.y-cell_size.y/2.0, center_cell.x*cell_size.x+cell_size.x/2.0)
	grid_items.append(grid_item)
	add_child(grid_item)
func move_item(grid_item: Node2D, new_center_cell: Vector2):
	grid_item.position = Vector2(new_center_cell.y*cell_size.y-cell_size.y/2.0, new_center_cell.x*cell_size.x+cell_size.x/2.0)
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
