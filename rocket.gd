extends RigidBody2D

func _ready():
	for tetromino in get_children():
		for child in tetromino.get_children():
			#print(tetromino.get_children().size())
			var child_duplicate = child.duplicate()
			add_child(child_duplicate)
			child_duplicate.position += tetromino.position
			#child_duplicate.rotation = 1.0
			var pivot_point = tetromino.position  # point to rotate around
			var angle = tetromino.rotation

			# Offset from pivot to current position
			var offset = child_duplicate.position - pivot_point

			# Rotate the offset
			offset = offset.rotated(angle)

			# Set the new position
			child_duplicate.position = pivot_point + offset

			# Finally apply the rotation
			child_duplicate.rotation += angle

			print(tetromino.global_rotation)
			
			tetromino.remove_child(child)
		
	#var points : Array[Vector2]
	#for tetromino : Tetromino in get_children():
		#tetromino.freeze = true
		#var tshape = tetromino.collision_shape
		#points.append(tshape.position)
		#points.append(tshape.position+Vector2(tetromino.size.x, 0))
		#points.append(tshape.position+tetromino.size)
		#points.append(tshape.position+Vector2(0, tetromino.size.y))
	#var collison_poly = ConvexPolygonShape2D.new()
	#collison_poly.points = points
	#var collision_shape = CollisionShape2D.new()
	#collision_shape.shape = collison_poly
	#print(collison_poly.points)
	#add_child(collision_shape)
