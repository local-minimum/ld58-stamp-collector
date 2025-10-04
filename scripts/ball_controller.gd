extends RigidBody3D
class_name BallController

@export var rotation_speed: float = 10

var start_positon: Vector3
var _acceleration: Vector3
var _started: bool

func _ready() -> void:
    start_positon = global_position
    if __SignalBus.on_player_death.connect(kill) != OK:
        push_error("Failed to connect player death")

func _input(event: InputEvent) -> void:
    var x: float = event.get_action_strength("roll_west") - event.get_action_strength("roll_east")
    var z: float = event.get_action_strength("roll_north") - event.get_action_strength("roll_south")
    _acceleration = Vector3(x, 0, z)

func _process(delta: float) -> void:
    if !_started && _acceleration != Vector3.ZERO:
        _started = true
        __SignalBus.on_start_run.emit()

    angular_velocity += delta * _acceleration * rotation_speed

func kill() -> void:
    linear_velocity = Vector3.ZERO
    angular_velocity = Vector3.ZERO
    _acceleration = Vector3.ZERO
    global_position = start_positon
    _started = false
