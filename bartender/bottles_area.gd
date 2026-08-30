class_name AreaManager
extends Node3D

## Emitted when trying to add a bottle but no free slots remain.
signal area_full

@export var slots: Array[BottleSlot] = []
@export var other_area : AreaManager


func _ready() -> void:
	# Automatically gather child slots if not assigned manually in the Inspector
	if slots.is_empty():
		for child in get_children():
			if child is BottleSlot:
				slots.append(child)
	for slot in slots:
		if slot.current_bottle != null:
			slot.current_bottle.move_bottle.connect(send_bottle_to_other_area)


## Returns the first unoccupied slot, or null if all slots are filled.
func get_free_slot() -> BottleSlot:
	for slot in slots:
		if not slot.is_occupied:
			return slot
	return null


## Checks if there is space available in this area.
func has_free_slot() -> bool:
	return get_free_slot() != null

func has_bottle(bottle : Bottle) -> bool:
	for slot in slots:
		if slot.current_bottle == bottle:
			return true
	return false

## Attempts to store a bottle in this area. Returns true if successful.
func try_receive_bottle(bottle: Bottle) -> bool:
	var free_slot := get_free_slot()
	if free_slot == null:
		area_full.emit()
		return false
	
	return true

#receive a bottle
func receive_bottle(bottle: Bottle) -> void:
	for slot in slots:
		if slot.current_bottle == null:
			slot.assign_bottle(bottle)
			bottle.move_bottle.connect(send_bottle_to_other_area)
			return


## Frees the slot occupied by the specified bottle.
func release_bottle(bottle: Bottle) -> void:
	for slot in slots:
		if slot.current_bottle == bottle:
			bottle.move_bottle.disconnect(send_bottle_to_other_area)
			slot.clear_slot()
			return

func send_bottle_to_other_area(bottle : Bottle) -> void:
	#check if it actually has that bottle
	var bottle_is_here = has_bottle(bottle)
	if !bottle_is_here:
		return
	#check if can recieve bottle
	var can_receive_bottle = other_area.try_receive_bottle(bottle)
	if !can_receive_bottle:
		print("Cannot send a bottle, other area full")
		return
	#get rid of bottle from here
	release_bottle(bottle)
	#place bottle over there
	other_area.receive_bottle(bottle)
