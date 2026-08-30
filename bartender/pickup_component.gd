@tool
class_name PickupComponent
extends Node

@export var pickup_distance: float = 2.0  # Distance in front of camera [00:02:43]

const PICKUP_LERP: float = 0.3            # Speed for interpolating location [00:02:54]

var parent: InteractionComponent
var object: RigidBody3D
var picked_up: bool = false
var player_camera: Camera3D

func _ready() -> void:
	# Retrieve parent and connect interaction signal if valid [00:01:40]
	parent = get_parent() as InteractionComponent
	if parent and not Engine.is_editor_hint():
		parent.interacted.connect(update_state)

# Editor warning system if PickupComponent is placed incorrectly [00:01:17, 00:01:53]
func _get_configuration_warnings() -> PackedStringArray:
	if not get_parent() is InteractionComponent:
		return ["PickupComponent must be a child of an InteractionComponent."]
	return []

func _notification(what: int) -> void:
	# Refresh editor warning when node enters/moves in scene tree [00:02:13, 00:02:20]
	if what == NOTIFICATION_ENTER_TREE:
		parent = get_parent() as InteractionComponent
		update_configuration_warnings()

func update_state(interactable_body: RigidBody3D) -> void:
	# Toggle pickup / drop state [00:03:00, 00:03:38]
	if picked_up:
		# Drop object [00:03:44]
		picked_up = false
		if object:
			object.freeze = false
			object = null
	else:
		# Pick up object [00:03:08]
		object = interactable_body
		if object:
			object.freeze = true  # Disable physics/gravity while held [00:03:08]
			picked_up = true
			
			# Cache reference to the active player's camera [00:03:57]
			if not player_camera:
				player_camera = get_viewport().get_camera_3d()

func _physics_process(_delta: float) -> void:
	# Smoothly move object relative to player camera transform [00:03:51, 00:03:57]
	#FOLLOW THE MOUSE HERE
	
	#KEEP y the Same 
	#THEREFORE, THIS NEEDS CONSTANT UPDATES FROM THE RAYCAST, OR get mouse here
	
	# Follow Mouse
	#when let go move back to the original position
	if picked_up and object and player_camera:
		var target_transform = player_camera.global_transform
		target_transform.origin += -target_transform.basis.z * pickup_distance
		object.global_transform = object.global_transform.interpolate_with(target_transform, PICKUP_LERP)
