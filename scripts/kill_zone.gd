extends Node

func _on_body_entered(body:Node3D) -> void:
    if body is BallController:
        __SignalBus.on_player_death.emit()
