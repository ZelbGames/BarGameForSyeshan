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

#return the point in 3D space, fixed on the z axis, based on
#where the mouse is positioned
#NOTE can do infs!
func raycast_point_fixed_on_x_axis(x_coordinate : float) -> Vector3:
	global_position = camera.global_position
	if !camera:
		printerr("No Camera Found: Line 32, camera_ray_caster.gd ")
		return Vector3.ZERO
	var viewport := get_viewport()
	
	var mouse_pos := viewport.get_mouse_position()
	var point_1 : Vector3= camera.project_ray_origin(mouse_pos)
	var point_2 : Vector3 = point_1 + camera.project_ray_normal(mouse_pos)  * ray_length
	
	#calculate the point using parametric equations
	var constant : float = (x_coordinate - point_1.x)/(point_2.x - point_1.x)
	var point_y : float = point_1.y + constant * (point_2.y - point_1.y)
	var point_z : float = point_1.z + constant * (point_2.z - point_1.z)
	
	return Vector3(x_coordinate, point_y, point_z)

@export var bottle_highlight : MeshInstance3D
