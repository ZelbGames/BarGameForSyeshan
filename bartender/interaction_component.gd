class_name InteractionComponent
extends Node3D

# Signal emitted when interacted with, passing the parent RigidBody3D [00:00:53]
signal interacted(body: RigidBody3D)

func interact() -> void:
	# Get the parent RigidBody3D object [00:00:53]
	var parent_body = get_parent() as RigidBody3D
	if parent_body:
		interacted.emit(parent_body)
