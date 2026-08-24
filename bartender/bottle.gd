extends StaticBody3D

var has_been_hit : bool = false
@onready var highlight: MeshInstance3D = $Highlight
@export var player : CharacterBody3D

func _ready() -> void:
	player.connect("hide_bottle_highlight", hide_highlight)

func hide_highlight() -> void:
	highlight.hide()
	pass
