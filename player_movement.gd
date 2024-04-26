extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum Side {RIGHT, LEFT, FLAT}

func print_side(side):
	if side == Side.RIGHT:
		print("RIGHT")
	elif side == Side.LEFT:
		print("LEFT")
	elif side == Side.FLAT:
		print("FLAT")
	else:
		printerr("Side not implemented: ", side)
	
func _find_side():
	var rotation_position = (round(rad_to_deg(rotation.z) + 45.) as int % 90) - 45
	if rotation_position == 0:
		return Side.FLAT
	elif rotation_position < 0:
		return Side.RIGHT
	else:
		return Side.LEFT

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	var side = _find_side()
	print_side(side)

	move_and_slide()
