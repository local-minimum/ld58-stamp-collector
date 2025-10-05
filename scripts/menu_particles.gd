extends Node

@export var goal: Node3D
@export var stamps: Array[Node3D]
@export var interval_min: float =  0.1
@export var interval_max: float =  0.5

func _ready() -> void:
    _fireworks()

func _fireworks() -> void:
    emit_particles(goal)

    await get_tree().create_timer(randf_range(interval_min, interval_max)).timeout

    for stamp: Node3D in stamps:
        emit_particles(stamp)

        await get_tree().create_timer(randf_range(interval_min, interval_max)).timeout

func emit_particles(n: Node3D) -> void:
    if n == null:
        return

    for child: Node in n.find_children("", "GPUParticles3D"):
        if child is GPUParticles3D:
            var part: GPUParticles3D = child
            part.restart()
