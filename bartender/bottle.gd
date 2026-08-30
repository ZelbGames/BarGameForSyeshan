class_name Bottle
extends RigidBody3D

signal pouring_drink(drink_name : String, pour_speed : float, drink_colour : Color)
signal stop_pouring
signal move_bottle(bottle : Bottle)

@onready var highlight: MeshInstance3D = $Highlight
@export var player : CharacterBody3D
#can be done with a signal on the bottle
#@export var current_container : AreaManager

@export_category("Bottle Info")
@export var drink_name : String = "Water"
@export var pour_speed : float = 25.0 #the amount of liquid poured into a glass per second
@export var height_ofset : float = 0.1
@export var drink_colour : Color = Color.RED

func _ready() -> void:
	player.connect("hide_bottle_highlight", hide_highlight)

func hide_highlight() -> void:
	highlight.hide()

func pour_drink() -> void:
	var glass = get_tree().get_nodes_in_group("CurrentlySelectedGlass")
	pouring_drink.emit(drink_name, pour_speed, drink_colour)

func stop_pour() -> void:
	stop_pouring.emit()

#basically the move bottle
func pickup_bottle() -> void:
	move_bottle.emit(self)
