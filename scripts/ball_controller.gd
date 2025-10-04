extends RigidBody3D
class_name BallController

@export var rotation_speed: float = 10
@export var stamp_versions: Array[Node3D]
@export var stamp_colliders: Array[CollisionShape3D]

var start_positon: Vector3
var _acceleration: Vector3
var _started: bool
var _level_completed: bool

func _ready() -> void:
    start_positon = global_position
    if __SignalBus.on_player_death.connect(kill) != OK:
        push_error("Failed to connect player death")

    if __SignalBus.on_level_completed.connect(_handle_complete_level) != OK:
        push_error("Failed to connect level completed")

    if __SignalBus.on_collect_stamp.connect(_handle_collect_stamp) != OK:
        push_error("Failed to connect collect stamp")

    _sync(0)

var _collected_stamps: Array[CollectableStamp]

func _sync(stamps: int) -> void:
    for idx: int in range(stamp_versions.size()):
        stamp_versions[idx].visible = idx == stamps

    for idx: int in range(stamp_colliders.size()):
        stamp_colliders[idx].set_deferred("disabled", idx > stamps)

func _handle_collect_stamp(stamp: CollectableStamp) -> void:
    if !_collected_stamps.has(stamp):
        _collected_stamps.append(stamp)
        _sync(_collected_stamps.size())

func _input(event: InputEvent) -> void:
    var x: float = event.get_action_strength("roll_west") - event.get_action_strength("roll_east")
    var z: float = event.get_action_strength("roll_north") - event.get_action_strength("roll_south")
    _acceleration = Vector3(x, 0, z)

func _process(delta: float) -> void:
    if !_started && _acceleration != Vector3.ZERO:
        _started = true
        __SignalBus.on_start_run.emit()

    if _level_completed:
        angular_velocity *= 0.5
        linear_velocity *= 0.5
    else:
        angular_velocity += delta * _acceleration * rotation_speed


func kill() -> void:
    if _level_completed:
        return

    linear_velocity = Vector3.ZERO
    angular_velocity = Vector3.ZERO
    _acceleration = Vector3.ZERO
    global_position = start_positon
    _started = false
    _collected_stamps.clear()
    _sync(0)

func _handle_complete_level() -> void:
    _level_completed = true
