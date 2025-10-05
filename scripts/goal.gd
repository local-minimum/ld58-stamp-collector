extends Area3D
class_name Goal

@export var required_stamps_collected: int
@export var confetti: Array[GPUParticles3D]
@export var delay_before_load_next: float = 1.0
@export var go_to_menu_after: bool

var _collected_stamps: Array[CollectableStamp]
var _completed: bool

func _ready() -> void:
    if __SignalBus.on_start_run.connect(_handle_run_start) != OK:
        push_error("Failed to connect start run")

    if __SignalBus.on_collect_stamp.connect(_handle_collect_stamp) != OK:
        push_error("Failed to connect collect stamp")

    if __SignalBus.on_resume_play.connect(_handle_resume_play) != OK:
        push_error("Failed to connect resume play")

    __SignalBus.on_set_required_stamps.emit(required_stamps_collected)

var _run_start: int

func _handle_run_start(time: int) -> void:
    _run_start = time
    _collected_stamps.clear()
    __SignalBus.on_set_required_stamps.emit(required_stamps_collected)

func _handle_resume_play(pause: int) -> void:
    _run_start += pause

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
        __SignalBus.on_level_completed.emit(self, maxi(0, Time.get_ticks_msec() - _run_start))
        for conf: GPUParticles3D in confetti:
            conf.restart()
        await get_tree().create_timer(delay_before_load_next).timeout
        if go_to_menu_after:
            __LevelsManager.transition_to_menu()
        else:
            __LevelsManager.transition_to_next_scene()
    else:
        __SignalBus.on_forgot_stamps.emit(required_stamps_collected - _collected_stamps.size())
