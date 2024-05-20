extends CharacterBody3D

var rng = RandomNumberGenerator.new()

var mouse_sensitivity := 0.001
var twist_input := 0.0
var pitch_input := 0.0
var action_bool := true
var dash_bool := false

var cutscene := false

@onready var walkingAudioPlayer = $AudioStreamPlayer_Walking
@onready var jumpingAudioPlayer = $AudioStreamPlayer_Jumping
@onready var dashingAudioPlayer = $AudioStreamPlayer_Dashing
@onready var landingAudioPlayer = $AudioStreamPlayer_Landing
@onready var wispSpawnAudioPlayer = $AudioStreamPlayer_WispSpawn
@onready var wispRecallAudioPlayer = $AudioStreamPlayer_WispRecall


@onready var blink_timer := $BlinkTimer
@onready var dash_cooldown_timer := $DashCooldown
@onready var jump_cooldown_timer := $DJCooldown
@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var mesh := $MeshInstance3D
@onready var camera := $TwistPivot/PitchPivot/Camera3D
@onready var animtree := $AnimationTree
@onready var animplayer := $AnimationPlayer
@onready var level := get_parent()
@onready var intrange := $InteractRange
@onready var walkparticles = $walkparticles
@onready var jumpparticles = $jumpparticles
@onready var dashparticles = $dashparticles

@onready var blackhole = $"../BlackHole"

signal recall_wisp(num)
signal assign_wisp_number(num)
var wispcount = 0
var wispmax = 3
var wispline = 1
var wisptotal = 0

const DASH_SPEED = 25.0
const DASH_TIME = 0.3
var dash_time_count = 0

const SPEED = 5.0
const JUMP_VELOCITY = 10
var angular_acceleration = 7
const TERM_FALL_VELOCITY = -15
signal levelend

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	visible = false

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
	
	match is_on_floor():
		true: 
			match  velocity != Vector3(0,0,0):
				true:
					walkparticles.emitting = true
				false:
					walkparticles.emitting = false
		false:
			walkparticles.emitting = false
		
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not cutscene:
		velocity.y = JUMP_VELOCITY
		animtree["parameters/JumpShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		jumpingAudioPlayer.play()
	
	
	# DOUBLE JUMP
	if Input.is_action_just_pressed("jump") and not is_on_floor() and not cutscene:
		if jump_cooldown_timer.time_left == 0:
			jump_cooldown_timer.start(1)
			velocity.y = JUMP_VELOCITY
			animtree["parameters/JumpShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
			jumpparticles.emitting = true
	
	
	#Get input direction and direction of camera
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y) * twist_pivot.basis.inverse()).normalized()
	
	#DASH
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer.time_left == 0 and direction and not cutscene:
		dash_cooldown_timer.start(1)
		dash_bool = true
		velocity = Vector3(direction.x * DASH_SPEED, 0, direction.z * DASH_SPEED)
		dashparticles.emitting = true
	
	if Input.is_action_just_pressed("wisp") and wisptotal < wispmax:
		spawn_wisp()
	
	if Input.is_action_just_pressed("recall") and wisptotal > 0:
		wisp_recall()
	
	#Movement
	if dash_bool:
		mesh.visible = false
		dash_time_count += delta
		if dash_time_count >= DASH_TIME:    
			dash_bool = false
			mesh.visible = true
			velocity = Vector3(0, 0, 0)
			dash_time_count = 0
	if not dash_bool and not cutscene:
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
		animtree["parameters/FallingBlend/blend_amount"] = 1.0
	else:
		animtree["parameters/Blend2/blend_amount"] = (abs(input_dir.x) + abs(input_dir.y))/2
		
	
	if is_on_floor():
		animtree["parameters/FallingBlend/blend_amount"] = 0
		animtree["parameters/JumpShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT
		
	if velocity.x != 0 or velocity.z != 0:
		var lookdir = atan2(velocity.x, velocity.z)
		mesh.rotation.y = lerp_angle(mesh.rotation.y, lookdir, delta * angular_acceleration)


func step_sound():
	walkingAudioPlayer.pitch_scale = rng.randf_range(0.01, 2)
	walkingAudioPlayer.play()

#Camera
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sensitivity
			pitch_input = - event.relative.y * mouse_sensitivity
#Mouse



func spawn_wisp():
	if wisptotal < 3:
		var wisp_scene = preload("res://Scenes/Objects/light_wisp.tscn")
		var wisp = wisp_scene.instantiate()
		wisp.position = Vector3(position.x, position.y + 0.5, position.z)
		level.add_child(wisp)
		if wispcount < 3:
			wispcount += 1
		else:
			wispcount = 1
		assign_wisp_number.emit(wispcount)
		wisptotal+=1
		wispSpawnAudioPlayer.play()
		

func wisp_recall():
	if wisptotal > 0:
		recall_wisp.emit(wispline)
		if wispline >= 3:
			wispline = 1
		else:
			wispline += 1
		wisptotal -= 1
		wispRecallAudioPlayer.play()






func _on_blink_timer_timeout():
	animplayer.play("blink")
	blink_timer.start(rng.randf_range(5, 10))





func _on_game_manager_level_completed():
	cutscene = true
	


func _on_cutscene_timer_timeout():
	camera.make_current()
	cutscene = false
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", blackhole.position, 3)
	tween.parallel().tween_property(mesh, "scale", Vector3(0,0,0),3)
	tween.chain().tween_callback(end_of_the_road)
	


func _on_black_hole_blackholeopen():
	visible = true
	position = blackhole.position


func _on_black_hole_blackholeclose():
	camera.make_current()

func end_of_the_road():
	levelend.emit()
	
