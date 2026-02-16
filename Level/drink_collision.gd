extends Area3D

@onready var whispers: AudioStreamPlayer3D = $Whispers

var can_end : bool = false

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.label.visible = true
		whispers.playing =  true
		can_end = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.label.visible = false
		whispers.playing = false
		can_end = true

func _input(event: InputEvent) -> void:
	if can_end and Input.is_action_just_pressed("interact"):
		get_tree().quit()
