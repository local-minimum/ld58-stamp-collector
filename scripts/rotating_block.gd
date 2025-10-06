extends Node3D

@export var speed: float = 10

func _process(delta: float) -> void:
    global_rotate(Vector3.UP, speed * delta)
