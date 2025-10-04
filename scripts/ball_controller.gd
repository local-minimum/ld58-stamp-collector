extends RigidBody3D
class_name BallController

@export var rotation_speed: float = 10

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

func _handle_complete_level() -> void:
    _level_completed = true
