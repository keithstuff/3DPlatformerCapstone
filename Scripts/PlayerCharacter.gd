extends CharacterBody3D

var mouse_sensitivity := 0.001
var twist_input := 0.0
var pitch_input := 0.0
@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var mesh := $MeshInstance3D
@onready var camera := $TwistPivot/PitchPivot/Camera3D
@onready var animtree := $AnimationTree
@onready var animplayer := $AnimationPlayer
const SPEED = 5.0
const JUMP_VELOCITY = 10
var angular_acceleration = 7
const TERM_FALL_VELOCITY = -15
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	pitch_pivot.rotation.x = clamp(
		$TwistPivot/PitchPivot.rotation.x,
		-0.5,
		0.5
	)
	
	twist_input = 0.0
	pitch_input = 0.0


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor() and velocity.y >= TERM_FALL_VELOCITY:
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animtree["parameters/OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y) * twist_pivot.basis.inverse()).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
	
	if(abs(input_dir.x) + abs(input_dir.y) >= 1) and is_on_floor():
		animtree["parameters/Blend2/blend_amount"] = 1.0
	elif not is_on_floor():
		animtree["parameters/FallingBlend/blend_amount"] = 1
	else:
		animtree["parameters/Blend2/blend_amount"] = (abs(input_dir.x) + abs(input_dir.y))/2
		
	
	if is_on_floor():
		animtree["parameters/FallingBlend/blend_amount"] = 0
		animtree["parameters/OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT
		
	if velocity.x != 0 or velocity.z != 0:
		var lookdir = atan2(velocity.x, velocity.z)
		mesh.rotation.y = lerp_angle(mesh.rotation.y, lookdir, delta * angular_acceleration)
			
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sensitivity
			pitch_input = - event.relative.y * mouse_sensitivity

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
