extends Node3D

@export var _required_level: String
@export var _load_level_idx: int
@export var _lid: Node3D
@export var _lid_collider: CollisionShape3D

var open: bool = false

func _ready() -> void:
    open = _required_level.is_empty() || __GlobalState.has_completed(_required_level)

    _lid.visible = !open
    _lid_collider.set_deferred("disabled", open)

func _on_hole_trigger_body_entered(body:Node3D) -> void:
    if body is BallController:
        if open:
            __LevelsManager.transition_to_scene(_load_level_idx)
