extends Area3D

@onready var whispers: AudioStreamPlayer3D = $Whispers
@onready var jump_scare_sound_effect: AudioStreamPlayer3D = $JumpScareSoundEffect

var can_end : bool = false

var player : CharacterBody3D

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.label.visible = true
		whispers.playing =  true
		can_end = true
		player = body


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.label.visible = false
		whispers.playing = false
		can_end = true

func _input(_event: InputEvent) -> void:
	if can_end and Input.is_action_just_pressed("interact"):
		jump_scare_sound_effect.play()
		player.texture_rect_2.visible = true
		await get_tree().create_timer(0.3).timeout
		player.texture_rect_3.visible = true
		await get_tree().create_timer(0.3).timeout
		player.texture_rect_4.visible = true
		await get_tree().create_timer(0.3).timeout
		player.texture_rect_5.visible = true
		get_tree().reload_current_scene()
		player.texture_rect_2.visible = false
		player.texture_rect_3.visible = false
		player.texture_rect_4.visible = false
		player.texture_rect_5.visible = false
		#get_tree().quit()
