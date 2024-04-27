extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum Side {RIGHT, LEFT, FLAT}

@export var offset = Vector2(0, 0)

func print_side(side):
	if side == Side.RIGHT:
		print("RIGHT")
	elif side == Side.LEFT:
		print("LEFT")
	elif side == Side.FLAT:
		print("FLAT")
	else:
		printerr("Side not implemented: ", side)
	
func _find_side_cube_is_leaning():
	var rotation_position = (round(rad_to_deg(rotation.z) + 45.) as int % 90) - 45
	if rotation_position == 0:
		return Side.FLAT
	elif rotation_position < 0:
		return Side.RIGHT
	else:
		return Side.LEFT

func _find_pivot_side(side_cube_is_leaning, input_direction):
	if side_cube_is_leaning == Side.FLAT:
		if input_direction > 0.:
			return Side.RIGHT
		elif input_direction < 0.:
			return Side.LEFT
		else:
			return Side.FLAT
	else:
		return side_cube_is_leaning

func _move_pivot(side):
	var rot = rad_to_deg(rotation.z) + 45.
	var down
	var left
	var col = get_node("CollisionShape3D")
	var mesh = get_node("MeshInstance3D")
	if rot >= 180. || rot < -90.:
		down = Vector2(0, 0.5)
		left = Vector2(0.5, 0)
	elif rot >= 90.:
		down = Vector2(-0.5, 0)
		left = Vector2(0, 0.5)
	elif rot >= 0.:
		down = Vector2(0, -0.5)
		left = Vector2(-0.5, 0)
	elif rot >= -90.:
		down = Vector2(0.5, 0)
		left = Vector2(0, -0.5)
	else:
		printerr("Bad pivot calc", rot)
 
	print("THIS ", position)
	print("COL ", col.position)
	
	if col.position && side == Side.FLAT:
		position = Vector3(position.x - offset.x, 0.5, 0)
		col.position = Vector3(0, 0, 0)
		mesh.position = Vector3(0, 0, 0)
		offset = Vector2(0, 0)
	elif !col.position && (side == Side.LEFT || side == Side.RIGHT):
		offset = down + (left if side == Side.LEFT else -left)
		position = Vector3(position.x + offset.x, 0, 0)
		col.position = Vector3(-offset.x, -offset.y, 0)
		mesh.position = Vector3(-offset.x, -offset.y, 0)

	print("OFFSET ", offset)
	print_side(side)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, 0)).normalized().x
	var side = _find_side_cube_is_leaning()
	var pivot_dir = _find_pivot_side(side, direction)
	_move_pivot(pivot_dir)

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
