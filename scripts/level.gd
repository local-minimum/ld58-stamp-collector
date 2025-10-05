extends Node
class_name Level

@export var level_id: String

var death_counter: int

var best_time_msec: int = -1
var current_time_msec: int = -1

func _enter_tree() -> void:
    if __SignalBus.on_player_death.connect(_handle_player_death) != OK:
        push_error("Failed to connect player death")

    if __SignalBus.on_level_completed.connect(_handle_level_completed) != OK:
        push_error("Failed to connnect level completed")

func _ready() -> void:
    best_time_msec = __GlobalState.get_best_time(level_id)
    death_counter = __GlobalState.get_deaths(level_id)
    current_time_msec = -1
    __SignalBus.on_update_level_stats.emit(self, false)

func _handle_player_death() -> void:
    death_counter += 1
    current_time_msec = -1
    __SignalBus.on_update_level_stats.emit(self, true)

func _handle_level_completed(time: int) -> void:
    current_time_msec = time
    if best_time_msec < 0:
        best_time_msec = current_time_msec
    else:
        best_time_msec = mini(best_time_msec, current_time_msec)

    print_debug("[Level] Run took %s (%s best)" % [current_time_msec, best_time_msec])

    __SignalBus.on_update_level_stats.emit(self, true)
