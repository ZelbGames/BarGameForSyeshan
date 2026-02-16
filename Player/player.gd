extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var eyes: Node3D = $Head/Eyes
@onready var camera_3d: Camera3D = $Head/Eyes/Camera3D

@onready var standing_collision: CollisionShape3D = $StandingCollision

@onready var label: Label = $CanvasLayer/Label


#Movement Variables
const walking_speed : float = 2.0
const sprint_speed : float = 5.0

var current_speed : float = 3.0 #could use getter setter to clamp
var moving : bool = false

var input_dir : Vector2 = Vector2.ZERO
var direction : Vector3 = Vector3.ZERO

var lerp_speed : float = 10.0

#Player Settings
@export var mouse_sensitivity : float = 0.2
@export var base_fov : float = 75.0

#State Machine
enum PlayerState {
	IDLE_STAND,
	WALKING,
	SPRINTING,
	AIR
}

var player_state : PlayerState = PlayerState.IDLE_STAND

#headbobbing_variables
const head_bob_sprint_speed :float = 22.0
const head_bob_walking_speed :float = 14.0

const head_bob_sprint_intensity :float = 0.2
const head_bob_walk_intensity :float = 0.1

var head_bobbing_current_intensity : float = 0.0
var head_bobbing_vector : Vector2 = Vector2.ZERO
var head_bobbing_index : float = 0.0 #how far in the sin function



#Functions
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED #traps cursor in game

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x) * mouse_sensitivity )
		head.rotate_x( deg_to_rad(-event.relative.y) * mouse_sensitivity )
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-85.0), deg_to_rad(85.0))
	

func _physics_process(delta: float) -> void:
	
	update_player_state()
	update_camera(delta)
	
	#jump logic
	if not is_on_floor():
		if velocity.y >= 0:
			velocity += get_gravity() * delta
		else:
			velocity += get_gravity() * delta * 2.0
	
	input_dir = Input.get_vector("left","right","forward","backwards")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * 10.0 )
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	move_and_slide()


func update_player_state() -> void:
	moving = (input_dir != Vector2.ZERO)
	if not is_on_floor():
		player_state = PlayerState.AIR
	else:
		if not moving:
			player_state = PlayerState.IDLE_STAND
		elif Input.is_action_pressed("sprint"):
			player_state = PlayerState.SPRINTING
		else:
			player_state = PlayerState.WALKING
	
	update_player_speed(player_state)
	pass

func update_player_speed(_player_state : PlayerState) -> void:
	if _player_state == PlayerState.WALKING:
		current_speed = walking_speed
	elif _player_state == PlayerState.SPRINTING:
		current_speed = sprint_speed


func update_camera(delta : float) -> void:
	if player_state == PlayerState.AIR:
		pass
	
	if player_state == PlayerState.IDLE_STAND:
		camera_3d.fov = lerp(camera_3d.fov, base_fov, delta * lerp_speed)
		head_bobbing_current_intensity = head_bob_walk_intensity
		head_bobbing_index += head_bob_walking_speed * delta
	elif player_state == PlayerState.WALKING:
		camera_3d.fov = lerp(camera_3d.fov, base_fov, delta * lerp_speed)
		head_bobbing_current_intensity = head_bob_walk_intensity
		head_bobbing_index += head_bob_walking_speed * delta
	elif player_state == PlayerState.SPRINTING:
		camera_3d.fov = lerp(camera_3d.fov, base_fov * 1.3, delta * lerp_speed)
		head_bobbing_current_intensity = head_bob_sprint_intensity
		head_bobbing_index += head_bob_sprint_speed * delta
	
	head_bobbing_vector.y = sin(head_bobbing_index)
	head_bobbing_vector.x = sin(head_bobbing_index/2.0) + 0.5
	if moving:
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y * (head_bobbing_current_intensity /2.0) , delta* lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x * (head_bobbing_current_intensity ) , delta* lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0 , delta* lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0 , delta* lerp_speed)
