extends Control

@onready var left: Button = $Left
@onready var right: Button = $Right
@onready var down: Button = $Down
@onready var up: Button = $Up

@export var static_player : StaticPlayer


func _ready() -> void:
	update_buttons()

func update_buttons() -> void:
	if !static_player:
		return
	
	if static_player.currently_looking_at == 1:
		down.hide()
		up.show()
	else:
		up.hide()
		down.show()

var can_move_camera : bool = true
#disable the buttons whilst moving the camera
func use_button(is_lr : bool) -> void:
	can_move_camera = false
	update_buttons()  #update the buttons after any movement
	await get_tree().create_timer(static_player.camera_speed).timeout
	can_move_camera = true
	if is_lr:
		left.show()
		right.show()

func _on_left_mouse_entered() -> void:
	if !can_move_camera:
		return
	static_player.camera_3d.rotate_y(0.001) # so it rotates the right way
	if static_player.currently_looking_at == 2:
		UiSignals.look_at_customer.emit()
	else:
		UiSignals.look_at_drinks.emit()
	left.hide()
	use_button(true)



func _on_up_mouse_entered() -> void:
	if !can_move_camera:
		return
	UiSignals.look_at_customer.emit()
	use_button(false)



func _on_down_mouse_entered() -> void:
	if !can_move_camera:
		return
	UiSignals.look_at_recipe.emit()
	use_button(false)



func _on_right_mouse_entered() -> void:
	if !can_move_camera:
		return
	static_player.camera_3d.rotate_y(-0.001)# so it rotates the right way
	if static_player.currently_looking_at == 2:
		UiSignals.look_at_customer.emit()
	else:
		UiSignals.look_at_drinks.emit()
	right.hide()
	use_button(true)
