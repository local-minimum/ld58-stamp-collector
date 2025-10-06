extends Node

var _triggerd: bool

func _on_body_entered(body:Node3D) -> void:
    if _triggerd:
        return

    if body is BallController:
        _triggerd = true
        __LevelsManager.transition_to_special(LevelsManager.SpecialScene.MENU)
