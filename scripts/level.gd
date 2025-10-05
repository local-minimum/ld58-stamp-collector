extends Node
class_name Level

@export var level_id: String

var death_counter: int

var best_time_msec: int = -1
var current_time_msec: int = -1
var _run_start: int

func _enter_tree() -> void:
    if __SignalBus.on_player_death.connect(_handle_player_death) != OK:
        push_error("Failed to connect player death")

    if __SignalBus.on_start_run.connect(_handle_run_start) != OK:
        push_error("Failed to connect run start")

    if __SignalBus.on_level_completed.connect(_handle_level_completed) != OK:
        push_error("Failed to connnect level completed")

func _ready() -> void:
    best_time_msec = __GlobalState.get_best_time(level_id)
    death_counter = __GlobalState.get_deaths(level_id)

func _handle_player_death() -> void:
    death_counter += 1
    current_time_msec = -1
    __SignalBus.on_update_level_stats.emit(self)

func _handle_run_start() -> void:
    _run_start = Time.get_ticks_msec()

func _handle_level_completed() -> void:
    current_time_msec = Time.get_ticks_msec() - _run_start
    if best_time_msec < 0:
        best_time_msec = current_time_msec
    else:
        best_time_msec = mini(best_time_msec, current_time_msec)

    print_debug("[Level] Run took %s (%s best)" % [current_time_msec, best_time_msec])

    __SignalBus.on_update_level_stats.emit(self)
