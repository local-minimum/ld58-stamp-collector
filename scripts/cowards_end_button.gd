extends Node

@export var button: Button
@export var triggers: Array[Control]
@export var allow_after_avoids: int = 10

var _active_idx: int = -1
var _start_postion: Vector2

var _clicked: bool = false
var _avoids: int = 0
var _visible: bool

func _ready() -> void:
    if __SignalBus.on_start_run.connect(_handle_run_start) != OK:
        push_error("Failed to connect run start")

    if __SignalBus.on_player_death.connect(_handle_player_death) != OK:
        push_error("Failed to connect player death")

    _visible = true
    _start_postion = button.global_position

func _handle_run_start(_time: int) -> void:
    button.hide()
    for trigger: Control in triggers:
        trigger.hide()
    _visible = false

func _handle_player_death() -> void:
    button.show()
    for trigger: Control in triggers:
        trigger.show()
    _visible = true
    _avoids = 0

func _handle_avoid(from: int, to: int) -> void:
    if !_visible || _avoids > allow_after_avoids:
        return

    button.global_position = triggers[to].global_position
    _active_idx = from
    _avoids += 1

func _handle_exit_avoid(idx: int) -> void:
    if _active_idx == idx:
        if _visible:
            button.global_position = _start_postion
        _active_idx = -1


func _on_cowards_end_pressed() -> void:
    if _clicked:
        return

    _clicked = true
    __LevelsManager.transition_to_special(LevelsManager.SpecialScene.COWARDS_END)

func _on_texture_rect_mouse_exited() -> void:
    _handle_exit_avoid(0)

func _on_texture_rect_mouse_entered() -> void:
    _handle_avoid(0, 2)

func _on_texture_rect_2_mouse_entered() -> void:
    _handle_avoid(1, 3)

func _on_texture_rect_2_mouse_exited() -> void:
    _handle_exit_avoid(1)

func _on_texture_rect_3_mouse_entered() -> void:
    _handle_avoid(2, 0)

func _on_texture_rect_3_mouse_exited() -> void:
    _handle_exit_avoid(2)

func _on_texture_rect_4_mouse_entered() -> void:
    _handle_avoid(3, 1)

func _on_texture_rect_4_mouse_exited() -> void:
    _handle_exit_avoid(3)
