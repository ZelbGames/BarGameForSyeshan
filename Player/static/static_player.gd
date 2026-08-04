class_name StaticPlayer
extends CharacterBody3D

enum LookingAt {
	CUSTOMER,
	RECIPE,
	DRINKS
}

var currently_looking_at : LookingAt = LookingAt.CUSTOMER

@onready var customer_position: Node3D = $CustomerPosition
@onready var recipe_position: Node3D = $RecipePosition
@onready var drinks_position: Node3D = $DrinksPosition

var positions_to_look_at : Array[Vector3] = []

@onready var camera_3d: Camera3D = $Head/Eyes/Camera3D

#time in seconds to switch between camera positions
@export var camera_speed : float = 1.0

func _ready() -> void:
	camera_3d.look_at(customer_position.global_position)
	positions_to_look_at.append(customer_position.global_position)
	positions_to_look_at.append(recipe_position.global_position)
	positions_to_look_at.append(drinks_position.global_position)
	
	connect_signals()

func connect_signals() -> void:
	UiSignals.look_at_customer.connect(look_at_customer)
	UiSignals.look_at_recipe.connect(look_at_recipe)
	UiSignals.look_at_drinks.connect(look_at_drinks)


#currently want to only use the UI
#func _input(event: InputEvent) -> void:
	##Should replace this with the command patter
	#if event.is_action_released("left"):
		#look_at_prev_position()
	#if event.is_action_released("right"):
		#look_at_next_position()


#CAMERA MOVEMENT -----------------------------
func look_at_next_position() -> void:
	var next_pos_index = (currently_looking_at + 1 ) % 3
	#sets an enum by an int value
	currently_looking_at = next_pos_index as LookingAt
	look_at_smooth(positions_to_look_at[next_pos_index])
	#camera_3d.look_at(positions_to_look_at[next_pos_index])

func look_at_prev_position() -> void:
	var prev_pos_index = (currently_looking_at - 1 ) % 3
	#sets an enum by an int value
	currently_looking_at = prev_pos_index as LookingAt
	look_at_smooth(positions_to_look_at[prev_pos_index])
	#camera_3d.look_at(positions_to_look_at[prev_pos_index])

#SPECIFIC MOVEMENTS
func look_at_customer() -> void:
	currently_looking_at = LookingAt.CUSTOMER
	look_at_smooth(positions_to_look_at[LookingAt.CUSTOMER])

func look_at_recipe() -> void:
	currently_looking_at = LookingAt.RECIPE
	look_at_smooth(positions_to_look_at[LookingAt.RECIPE])

func look_at_drinks() -> void:
	currently_looking_at = LookingAt.DRINKS
	look_at_smooth(positions_to_look_at[LookingAt.DRINKS])

#SMOOTH CAMERA MOVEMENT---------------------
#ALL THIS COULD AND SHOULD BE ON THE CAMERA
#Smooth look at a target
var start_basis : Basis
var look_at_target : Transform3D
var tween : Tween
func look_at_smooth(pos : Vector3) -> void:
	look_at_target = camera_3d.global_transform.looking_at(pos, Vector3.UP)
	start_basis = camera_3d.global_basis
	create_tween().tween_method(interpolate, 0.0, 1.0, camera_speed).set_trans(Tween.TRANS_EXPO)


#from the docs V
func interpolate(weight : float):
	camera_3d.global_basis = start_basis.slerp(look_at_target.basis , weight)
