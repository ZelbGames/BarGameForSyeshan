class_name BottleSlot
extends Marker3D

## Indicates whether a bottle is currently occupying this slot.
@export var is_occupied: bool = false
## Reference to the bottle object occupying this slot, if any.
var current_bottle: Bottle = null
var parent_container : AreaManager

func _ready() -> void:
	parent_container = get_parent()
	#initialise bottle
	if !is_occupied:
		if get_child_count() == 1:
			current_bottle = get_child(0)

func assign_bottle(bottle: Bottle) -> void:
	is_occupied = true
	current_bottle = bottle
	#move the bottle
	#here just incase the bottle has been reparented elsewhere
	if get_child_count() == 0:
		current_bottle.reparent(self,true)
	current_bottle.position = Vector3(0.0, bottle.height_ofset, 0.0)

func clear_slot() -> void:
	is_occupied = false
	current_bottle = null
