extends Control

@export var container: Control
@export var level_name: Label
@export var level_deaths: Label
@export var level_record: Label

var showing: Array[int]

func _ready() -> void:
    if __SignalBus.on_menu_show_level_info.connect(_handle_show_info) != OK:
        push_error("Failed to connect show level info")

    if __SignalBus.on_menu_hide_level_info.connect(_handle_hide_info) != OK:
        push_error("Failed to connect hide level info")

    _sync()

func _handle_show_info(idx: int) -> void:
    showing.erase(idx)
    showing.append(idx)
    print_debug("[Level Info] Level %s" % idx)
    _sync()

func _handle_hide_info(idx: int) -> void:
    showing.erase(idx)
    _sync()

func _sync() -> void:
    if showing.is_empty():
        container.visible = false
        return

    var idx: int = showing[-1]
    var level_id: String = __LevelsManager.level_ids[idx] if __LevelsManager.level_ids.size() > idx else ""
    if level_id.is_empty():
        container.visible = false
        return

    level_name.text = __LevelsManager.level_names[idx] if __LevelsManager.level_names.size() > idx else "???"

    level_deaths.text = "%s" % __GlobalState.get_deaths(level_id)

    var record: int = __GlobalState.get_best_time(level_id)
    if record >= 0:
        level_record.text = "%.3fs" % (record / 1000.0)
    else:
        level_record.text = "---"

    container.visible = true
