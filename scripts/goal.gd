extends Area3D
class_name Goal

@export var required_stamps_collected: int

var _collected_stamps: Array[CollectableStamp]

func _ready() -> void:
    if __SignalBus.on_start_run.connect(_handle_run_start) != OK:
        push_error("Failed to connect start run")

    if __SignalBus.on_collect_stamp.connect(_handle_collect_stamp) != OK:
        push_error("Failed to connect collect stamp")

func _handle_run_start() -> void:
    _collected_stamps.clear()

func _handle_collect_stamp(stamp: CollectableStamp) -> void:
    if !_collected_stamps.has(stamp):
        _collected_stamps.append(stamp)

func _on_body_entered(body:Node3D) -> void:
    if body is not BallController:
        return

    if _collected_stamps.size() >= required_stamps_collected:
        __SignalBus.on_level_completed.emit()
    else:
        __SignalBus.on_forgot_stamps.emit(required_stamps_collected - _collected_stamps.size())
