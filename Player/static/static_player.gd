class_name StaticPlayer
extends CharacterBody3D

signal hide_bottle_highlight


enum LookingAt {
	CUSTOMER,
	RECIPE,
	DRINKS
}

var currently_looking_at : LookingAt = LookingAt.CUSTOMER

@export var ray_cast : Node3D

@onready var customer_position: Node3D = $CustomerPosition
@onready var recipe_position: Node3D = $RecipePosition
@onready var drinks_position: Node3D = $DrinksPosition

var positions_to_look_at : Array[Vector3] = []

@onready var camera_3d: Camera3D = $Head/Eyes/Camera3D

#time in seconds to switch between camera positions
@export var camera_speed : float = 1.0

var can_pour : bool = false

func _ready() -> void:
	camera_3d.look_at(customer_position.global_position)
	positions_to_look_at.append(customer_position.global_position)
	positions_to_look_at.append(recipe_position.global_position)
	positions_to_look_at.append(drinks_position.global_position)
	
	connect_signals()

var current_highlighted_bottle : Bottle
func _physics_process(delta: float) -> void:
	#highlight drinks and collide them
	if (currently_looking_at == LookingAt.DRINKS or currently_looking_at == LookingAt.CUSTOMER) and ray_cast:
		var hits : Dictionary = ray_cast.raycast_from_mouse()
		var collider = hits.get("collider")
		if collider: 
				collider.highlight.show()
				if collider != current_highlighted_bottle:
					current_highlighted_bottle = collider
		else:
			if current_highlighted_bottle:
				current_highlighted_bottle.stop_pour()
			current_highlighted_bottle = null
			hide_bottle_highlight.emit()
	else:
		current_highlighted_bottle = null
		hide_bottle_highlight.emit()
		if current_highlighted_bottle:
			current_highlighted_bottle.stop_pour()



func _input(event: InputEvent) -> void:
	#pour drink
	if event.is_action_pressed("primary") and can_pour:
		if current_highlighted_bottle:
			current_highlighted_bottle.pour_drink()
	if event.is_action_released("primary"):
		if current_highlighted_bottle:
			current_highlighted_bottle.stop_pour()
	
	#move the bottle
	if event.is_action_released("seconday") and current_highlighted_bottle:
		current_highlighted_bottle.pickup_bottle()
	
	if event.is_action_released("interact") and current_highlighted_bottle:
		check_interaction()


func check_interaction() -> void:
	# Check if the raycast is hitting an interactable object [00:00:41]
	if current_highlighted_bottle:
		
		# Locate the InteractionComponent on the hit object
		var interaction_component = current_highlighted_bottle.get_node_or_null("InteractionComponent") as InteractionComponent
		if interaction_component:
			interaction_component.interact()


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
#DEPRICATED
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
	can_pour = true

func look_at_recipe() -> void:
	currently_looking_at = LookingAt.RECIPE
	look_at_smooth(positions_to_look_at[LookingAt.RECIPE])
	can_pour = false

func look_at_drinks() -> void:
	currently_looking_at = LookingAt.DRINKS
	look_at_smooth(positions_to_look_at[LookingAt.DRINKS])
	can_pour = false

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
