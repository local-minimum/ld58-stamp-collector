extends Node3D

@export var player: BallController
@export var cam: Camera3D
@export var checkpoints: Array[Node3D]
@export var transition_times: Array[float]

@export var reset_duration: float = 0.5

var _cam_start_rotation: Quaternion

func _ready() -> void:
    _cam_start_rotation = cam.global_basis.get_rotation_quaternion()
    if __SignalBus.on_player_death.connect(reset_cam_to_start) != OK:
        push_error("Failed to connect player death")

    if __SignalBus.on_start_run.connect(_start_run) != OK:
        push_error("Failed to connect run start")

    reset_cam_to_start.call_deferred()

var _reset_tween: Tween

func reset_cam_to_start() -> void:
    if _reset_tween != null && _reset_tween.is_running():
        _reset_tween.kill()

    _reset_tween = create_tween()

    _reset_tween.tween_property(cam, "global_position", checkpoints[0].global_position if !checkpoints.is_empty() else Vector3.ZERO, reset_duration)
    var rotator: Callable = QuaternionUtils.create_tween_rotation_method(cam)
    var current_rotation = cam.global_basis.get_rotation_quaternion()
    _reset_tween.parallel().tween_method(
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

func _process(_delta: float) -> void:
    if !_started:
        return

    var now: float = Time.get_ticks_msec() / 1000.0
    var elapsed: float = now - _last_checkpoint
    var duration: float = transition_times[_checkpoint_idx] if _checkpoint_idx < transition_times.size() else 1.0

    var progress: float = clampf(elapsed / duration, 0.0, 1.0)

    var from: Vector3 = checkpoints[_checkpoint_idx].global_position if _checkpoint_idx < checkpoints.size() else Vector3.ZERO
    var to: Vector3 = checkpoints[_checkpoint_idx + 1].global_position if _checkpoint_idx < checkpoints.size() else Vector3.ZERO

    # print_debug("[Cam] progress %.2f from %s to %s" % [progress, from, to])
    if progress == 1.0:
        cam.global_position = to
        if _last_checkpoint + 1 < checkpoints.size():
            _last_checkpoint += 1
            _last_checkpoint = now
    else:
        cam.global_position = from.lerp(to, progress)
