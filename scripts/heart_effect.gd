extends Node3D

@export var _stamp: CollectableStamp
@export var _particles: GPUParticles3D

var _cam: Camera3D

func _enter_tree() -> void:
    if __SignalBus.on_ready_camera.connect(_handle_ready_camera) != OK:
        push_error("Failed to connect ready camera")

func _ready() -> void:
    if __SignalBus.on_collect_stamp.connect(_handle_collect_stamp) != OK:
        push_error("Failed to connect collect stamp")

func _handle_ready_camera(cam: Camera3D) -> void:
    _cam = cam

func _handle_collect_stamp(stamp: CollectableStamp) -> void:
    if _stamp != stamp:
        return

    global_rotation = Basis.looking_at(_cam.global_position - global_position, Vector3.UP).get_rotation_quaternion().get_euler()
    _particles.restart()
