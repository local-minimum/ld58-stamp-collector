extends Node3D

@export var _load_level_idx: int
@export var _lid: Node3D
@export var _lid_collider: CollisionShape3D
@export var _level_label: Label

var open: bool = false

func _ready() -> void:
    var required_leved: String = __LevelsManager.get_level_id(_load_level_idx - 1)
    open = _load_level_idx < __LevelsManager.level_ids.size() && (required_leved.is_empty() || __GlobalState.has_completed(required_leved))

    _lid.visible = !open
    _lid_collider.set_deferred("disabled", open)
    _level_label.text = "%s" % (_load_level_idx + 1)

func _on_hole_trigger_body_entered(body:Node3D) -> void:
    if body is BallController:
        if open:
            __LevelsManager.transition_to_scene(_load_level_idx)

func _on_proximity_body_entered(body: Node3D) -> void:
    if body is BallController:
        __SignalBus.on_menu_show_level_info.emit(_load_level_idx)

func _on_proximity_body_exited(body: Node3D) -> void:
    if body is BallController:
        __SignalBus.on_menu_hide_level_info.emit(_load_level_idx)
