extends CharacterBody3D

var mouse_sensitivity := 0.001
var twist_input := 0.0
var pitch_input := 0.0
var action_bool := true
var dash_bool := false
@onready var cooldown_timer := $ActionCooldown
@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var mesh := $MeshInstance3D
@onready var camera := $TwistPivot/PitchPivot/Camera3D
@onready var animtree := $AnimationTree
@onready var animplayer := $AnimationPlayer
@onready var level := get_parent()

signal recall_wisp(num)
signal assign_wisp_number(num)
var wispcount = 0
var wispmax = 3
var wispline = 1

const DASH_SPEED = 25.0
const DASH_TIME = 0.3
var dash_time_count = 0

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
	if not is_on_floor() and velocity.y >= TERM_FALL_VELOCITY and not dash_bool:
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animtree["parameters/OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	
	
	# DOUBLE JUMP
	if Input.is_action_just_pressed("jump") and not is_on_floor():
		if action_bool == true and cooldown_timer.time_left == 0:
			cooldown_timer.start(1)
			action_bool = false
			velocity.y = JUMP_VELOCITY
			animtree["parameters/OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		else:
			pass
	
	
	#Get input direction and direction of camera
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y) * twist_pivot.basis.inverse()).normalized()
	
	#DASH
	if Input.is_action_just_pressed("dash") and action_bool == true and cooldown_timer.time_left == 0 and direction:
		cooldown_timer.start(1)
		action_bool = false
		dash_bool = true
		velocity = Vector3(direction.x * DASH_SPEED, 0, direction.z * DASH_SPEED)
	
	if Input.is_action_just_pressed("wisp") and wispcount < wispmax:
		spawn_wisp()
	
	#Movement
	if dash_bool:
		dash_time_count += delta
		if dash_time_count >= DASH_TIME:    
			dash_bool = false
			velocity = Vector3(0, 0, 0)
			dash_time_count = 0
	if not dash_bool:
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, 1)
			velocity.z = move_toward(velocity.z, 0, 1)
	move_and_slide()
	
	#Falling and Running Animations
	if(abs(input_dir.x) + abs(input_dir.y) >= 1) and is_on_floor():
		animtree["parameters/Blend2/blend_amount"] = 1.0
	elif not is_on_floor():
		animtree["parameters/FallingBlend/blend_amount"] = 1
	else:
		animtree["parameters/Blend2/blend_amount"] = (abs(input_dir.x) + abs(input_dir.y))/2
		
	
	if is_on_floor():
		action_bool = true
		animtree["parameters/FallingBlend/blend_amount"] = 0
		animtree["parameters/OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT
		
	if velocity.x != 0 or velocity.z != 0:
		var lookdir = atan2(velocity.x, velocity.z)
		mesh.rotation.y = lerp_angle(mesh.rotation.y, lookdir, delta * angular_acceleration)
			
#Camera
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sensitivity
			pitch_input = - event.relative.y * mouse_sensitivity
#Mouse
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func spawn_wisp():
	var wisp_scene = preload("res://Scenes/light_wisp.tscn")
	var wisp = wisp_scene.instantiate()
	wisp.position = Vector3(position.x, position.y + 0.5, position.z)
	level.add_child(wisp)
	assign_wisp_number.emit(wispcount+1)
	

