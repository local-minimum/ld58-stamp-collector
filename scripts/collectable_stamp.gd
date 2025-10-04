extends Node
class_name CollectableStamp

@export var anim: AnimationPlayer
@export var stamp: Node3D

var _collected: bool

func _ready() -> void:
    anim.play("Default")
    if __SignalBus.on_player_death.connect(_handle_death) != OK:
        push_error("Failed to connect player death")


func _handle_death() -> void:
    _collected = false
    stamp.visible = true

func _on_body_entered(body:Node3D) -> void:
    if _collected:
        return

    if body is BallController:
        _collected = true
        stamp.visible = false
        __SignalBus.on_collect_stamp.emit(self)
