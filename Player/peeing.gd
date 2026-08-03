extends Node

@onready var pee_stream: GPUParticles3D = $"../PeeStream"


func pee() -> float:
	pee_stream.emitting = true
	return 0.0

func stop_pee() -> void:
	pee_stream.emitting = false
