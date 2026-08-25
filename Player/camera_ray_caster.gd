extends Node3D

@export var camera : Camera3D
@export_category("Parameters")
@export_custom(PROPERTY_HINT_LAYERS_3D_PHYSICS, "Collision Layer") var collision_mask : int = 2
@export var ray_length : float = 100.

#written by gemeni
func raycast_from_mouse() -> Dictionary:
	global_position = camera.global_position
	if !camera:
		return {}
	var viewport := get_viewport()
	
	
	var mouse_pos := viewport.get_mouse_position()
	var origin := camera.project_ray_origin(mouse_pos)
	var end := origin + camera.project_ray_normal(mouse_pos)  * ray_length
	
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(origin,end, collision_mask)
	
	var result : Dictionary = space_state.intersect_ray(query)
	
	return result

@export var bottle_highlight : MeshInstance3D
