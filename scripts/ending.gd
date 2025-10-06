extends Node

@export var remain_time: float = 8


func _ready() -> void:
    await get_tree().create_timer(remain_time).timeout
    __LevelsManager.transition_to_special(LevelsManager.SpecialScene.MENU)
