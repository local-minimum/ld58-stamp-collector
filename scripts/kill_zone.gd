extends Node

func _ready() -> void:
    if __SignalBus.on_level_completed.connect(_handle_level_complete) != OK:
        push_error("Failed to connect level completed")


var _disabled: bool

func _handle_level_complete(_time: int) -> void:
    _disabled = true

func _on_body_entered(body:Node3D) -> void:
    if _disabled:
        return

    if body is BallController:
        __SignalBus.on_player_death.emit()
