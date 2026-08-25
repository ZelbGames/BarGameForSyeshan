class_name Bottle
extends StaticBody3D

signal pouring_drink(drink_name : String, pour_speed : float)
signal stop_pouring

@onready var highlight: MeshInstance3D = $Highlight
@export var player : CharacterBody3D

@export_category("Bottle Info")
@export var drink_name : String = "Water"
@export var pour_speed : float = 25.0 #the amount of liquid poured into a glass per second

func _ready() -> void:
	player.connect("hide_bottle_highlight", hide_highlight)

func hide_highlight() -> void:
	highlight.hide()

func pour_drink() -> void:
	var glass = get_tree().get_nodes_in_group("CurrentlySelectedGlass")
	pouring_drink.emit(drink_name, pour_speed)

func stop_pour() -> void:
	stop_pouring.emit()
