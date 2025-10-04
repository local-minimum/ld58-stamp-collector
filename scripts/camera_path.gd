extends Node3D

@export var player: BallController
@export var cam: Camera3D
@export var checkpoints: Array[Node3D]
@export var transition_times: Array[float]

@export var reset_duration: float = 0.5
@export var cam_stamp_distance: float = 2.5
@export var cam_stamp_focus_in_duration: float = 0.5
@export var cam_stamp_stay_duration: float = 0.5

var _cam_start_rotation: Quaternion
var _level_completed: bool

func _ready() -> void:
    _cam_start_rotation = cam.global_basis.get_rotation_quaternion()
    if __SignalBus.on_player_death.connect(reset_cam_to_start) != OK:
        push_error("Failed to connect player death")

    if __SignalBus.on_start_run.connect(_start_run) != OK:
        push_error("Failed to connect run start")

    if __SignalBus.on_level_completed.connect(_handle_level_completed) != OK:
        push_error("Failed to connect level completed")

    if __SignalBus.on_collect_stamp.connect(_handle_collect_stamp) != OK:
        push_error("Failed to connect collect stamp")

    reset_cam_to_start.call_deferred()
    __SignalBus.on_ready_camera.emit(cam)

var _tween: Tween

func _handle_collect_stamp(stamp: CollectableStamp) -> void:
    if _tween != null && _tween.is_running():
        _tween.kill()

    _tween = create_tween()
    var inv_direction: Vector3 = (cam.global_position - stamp.stamp.global_position).normalized()
    var target: Vector3 = stamp.global_position + inv_direction * cam_stamp_distance

    _tween.tween_property(cam, "global_position", target, cam_stamp_focus_in_duration)

    var rotator: Callable = QuaternionUtils.create_tween_lookat_method(cam, stamp.stamp)
    _tween.parallel().tween_method(rotator, 0.0, 1.0, cam_stamp_focus_in_duration)

    _tween.tween_method(func (_f: float) -> void: pass, 0.0, 1.0, cam_stamp_stay_duration)

func _handle_level_completed() -> void:
    _level_completed = true

func reset_cam_to_start() -> void:
    if _level_completed:
        return

    if _tween != null && _tween.is_running():
        _tween.kill()

    _tween = create_tween()

    _tween.tween_property(cam, "global_position", checkpoints[0].global_position if !checkpoints.is_empty() else Vector3.ZERO, reset_duration)
    var rotator: Callable = QuaternionUtils.create_tween_rotation_method(cam)
    var current_rotation = cam.global_basis.get_rotation_quaternion()
    _tween.parallel().tween_method(
        rotator,
        current_rotation,
        _cam_start_rotation,
        reset_duration)

    _checkpoint_idx = 0
    _last_checkpoint = Time.get_ticks_msec() / 1000.0
    _started = false

func _start_run() -> void:
    _started = true
    _last_checkpoint = Time.get_ticks_msec() / 1000.0


var _started: bool
var _checkpoint_idx: int
var _last_checkpoint: float

func _process(delta: float) -> void:
    if !_started || _level_completed || _tween != null && _tween.is_running():
        return

    var now: float = Time.get_ticks_msec() / 1000.0
    var elapsed: float = now - _last_checkpoint
    var duration: float = transition_times[_checkpoint_idx] if _checkpoint_idx < transition_times.size() else 1.0

    var progress: float = clampf(elapsed / duration, 0.0, 1.0)

    var from: Vector3 = checkpoints[_checkpoint_idx].global_position if _checkpoint_idx < checkpoints.size() else Vector3.ZERO
    var to: Vector3 = checkpoints[_checkpoint_idx + 1].global_position if _checkpoint_idx < checkpoints.size() else Vector3.ZERO

    # print_debug("[Cam] progress %.2f from %s to %s" % [progress, from, to])
    if progress >= 1.0:
        cam.global_position = cam.global_position.lerp(to, delta)
        if _last_checkpoint + 1 < checkpoints.size():
            _checkpoint_idx += 1
            _last_checkpoint = now
            print_debug("[Cam] Reached checkpoint %s" % _checkpoint_idx)
    else:
        cam.global_position = cam.global_position.lerp(from.lerp(to, progress), delta)
