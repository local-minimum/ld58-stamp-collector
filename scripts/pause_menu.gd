extends Control

@export var level_name: Label
@export var deaths: Label
@export var prev: Button
@export var next: Button

var _pause_start: int

func _ready() -> void:
    hide()

func _on_resume_pressed() -> void:
    Engine.time_scale = 1
    hide()
    __SignalBus.on_resume_play.emit(maxi(0, Time.get_ticks_msec() - _pause_start))

func _on_previous_level_pressed() -> void:
    Engine.time_scale = 1
    __LevelsManager.transition_to_previous_scene()

func _on_next_level_pressed() -> void:
    Engine.time_scale = 1
    __LevelsManager.transition_to_next_scene()

func _on_menu_pressed() -> void:
    Engine.time_scale = 1
    __LevelsManager.transition_to_special(LevelsManager.SpecialScene.MENU)

func _show_menu() -> void:
    _pause_start = Time.get_ticks_msec()

    var current_id: String = __LevelsManager.level_id

    level_name.text = __LevelsManager.level_name
    deaths.text = "Deaths: %s" % __GlobalState.get_deaths(current_id)

    prev.visible = __LevelsManager.has_previous

    print_debug("[Pause] Has next %s, current level '%s' has been completed %s" % [__LevelsManager.has_next, __LevelsManager.level_id, __GlobalState.has_completed(__LevelsManager.level_id)])
    if __LevelsManager.has_next:
        if __GlobalState.has_completed(current_id):
            next.visible = true
        else:
            next.visible = false
    else:
        next.visible = false

    Engine.time_scale = 0
    show()


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("pause"):
        if visible:
            _on_resume_pressed()
        else:
            _show_menu()
