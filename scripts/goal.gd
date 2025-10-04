extends Area3D
class_name Goal

@export var required_stamps_collected: int
@export var confetti: Array[GPUParticles3D]
@export var delay_before_load_next: float = 1.0

var _collected_stamps: Array[CollectableStamp]
var _completed: bool

func _ready() -> void:
    if __SignalBus.on_start_run.connect(_handle_run_start) != OK:
        push_error("Failed to connect start run")

    if __SignalBus.on_collect_stamp.connect(_handle_collect_stamp) != OK:
        push_error("Failed to connect collect stamp")

    __SignalBus.on_set_required_stamps.emit(required_stamps_collected)

func _handle_run_start() -> void:
    _collected_stamps.clear()
    __SignalBus.on_set_required_stamps.emit(required_stamps_collected)

func _handle_collect_stamp(stamp: CollectableStamp) -> void:
    if !_collected_stamps.has(stamp):
        _collected_stamps.append(stamp)

func _on_body_entered(body:Node3D) -> void:
    if _completed:
        return

    if body is not BallController:
        return

    if _collected_stamps.size() >= required_stamps_collected:
        _completed = true
        __SignalBus.on_level_completed.emit()
        for conf: GPUParticles3D in confetti:
            conf.restart()
        await get_tree().create_timer(delay_before_load_next).timeout
        __LevelsManager.transition_to_next_scene()
    else:
        __SignalBus.on_forgot_stamps.emit(required_stamps_collected - _collected_stamps.size())
