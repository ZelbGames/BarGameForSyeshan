extends Area3D


var can_end : bool = false

var player : CharacterBody3D

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.label_2.visible = true
		can_end = true
		player = body


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.label_2.visible = false
		can_end = false

func _input(_event: InputEvent) -> void:
	if can_end and Input.is_action_just_pressed("interact"):
		get_tree().quit()
