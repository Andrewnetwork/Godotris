@tool
class_name Tetromino
extends RigidBody2D

enum TetrominoType {I,O,T,S,Z,J,L}
const TETROMINO_COLORS = {
	TetrominoType.I: Color.CYAN,
	TetrominoType.O: Color.YELLOW,
	TetrominoType.T: Color.MAGENTA,
	TetrominoType.S: Color.GREEN,
	TetrominoType.Z: Color.RED,
	TetrominoType.J: Color.BLUE,
	TetrominoType.L: Color.ORANGE
}
@export var type : TetrominoType
@export var size : Vector2 = Vector2(32,32)

func create_sprites(block_mask: Array[bool], n_rows: int, n_cols: int):

	for row in range(n_rows):
		for column in range(n_cols):
			if block_mask[row*n_cols + column]:
				
				var img = Image.create(1,1,false, Image.FORMAT_RGBA8)
				img.fill(TETROMINO_COLORS[type])
				var sprite = Sprite2D.new()
				sprite.material = ShaderMaterial.new()
				sprite.material.shader = load("res://Shaders/tetrino_cell.gdshader")
				sprite.texture = ImageTexture.create_from_image(img)
				sprite.scale = size
				var rect_shape = RectangleShape2D.new()
				rect_shape.size = size
				var collision_rect = CollisionShape2D.new()
				collision_rect.shape = rect_shape
				sprite.position.x = column*size.x
				sprite.position.y = row*size.y
				collision_rect.position = sprite.position
				add_child(sprite)
				add_child(collision_rect)

func _collision_detected(body: Node):
	#set_deferred("freeze", true)
	pass
func _init(type:TetrominoType=TetrominoType.I):
	self.type = type
	
func _ready():
	contact_monitor = true
	max_contacts_reported = 4
	freeze_mode = RigidBody2D.FreezeMode.FREEZE_MODE_STATIC
	body_entered.connect(_collision_detected)
	#create_sprites([0,1,0,1,1,1],2,3)
	if type == TetrominoType.I:
		create_sprites([1,1,1,1],1,4)
	elif type == TetrominoType.O:
		create_sprites([1,1,1,1],2,2)
	elif type == TetrominoType.J:
		create_sprites([1,0,0,1,1,1],2,3)
	elif type == TetrominoType.S:
		create_sprites([0,1,1,1,1,0],2,3)
	elif type == TetrominoType.T:
		create_sprites([0,1,0,1,1,1],2,3)
	elif type == TetrominoType.Z:
		create_sprites([1,1,0,0,1,1],2,3)
	elif type == TetrominoType.L:
		create_sprites([0,0,1,1,1,1],2,3)
		
func _process(delta: float):
	## Garbage collection
	var window_size = get_viewport().get_visible_rect().size
	if position.x < -300 || position.y < -300 || position.x > window_size.x+300 || position.y > window_size.y + 300:
		queue_free()
	
	
	 
