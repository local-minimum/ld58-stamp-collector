extends Node
class_name GlobalState

var _completed_levels: Array[String]
var _deaths: Dictionary[String, int]
var _best_times: Dictionary[String, int]

func _ready() -> void:
    if __SignalBus.on_update_level_stats.connect(_handle_update_level_stats) != OK:
        push_error("Failed to connect level stats updated")

func _handle_update_level_stats(level: Level, is_update: bool) -> void:
    if !is_update:
        return

    _deaths[level.level_id] = level.death_counter

    if level.best_time_msec >= 0:
        _best_times[level.level_id] = level.best_time_msec
    else:
        _best_times.erase(level.level_id)

    if level.current_time_msec >= 0 && !_completed_levels.has(level.level_id):
        _completed_levels.append(level.level_id)

func has_completed(level_id: String) -> bool:
    return !level_id.is_empty() && _completed_levels.has(level_id)


func get_deaths(level_id: String) -> int:
    return _deaths.get(level_id, 0)

var total_deaths: int:
    get():
        return ArrayUtils.sumi(Array(_deaths.values(), TYPE_INT, "", null))

func get_best_time(level_id: String) -> int:
    return _best_times.get(level_id, -1)

const _COMPLETED_KEY: String = "completed"
const _DEATHS_KEY: String = "deaths"
const _TIMES_KEY: String = "times"

func get_save_data() -> Dictionary:
    return {
        _COMPLETED_KEY: _completed_levels,
        _DEATHS_KEY: _deaths,
        _TIMES_KEY: _best_times
    }

func load_from_save(data: Dictionary) -> void:
    _completed_levels.clear()
    var completed: Array = DictionaryUtils.safe_geta(data, _COMPLETED_KEY)
    for lvl: Variant in completed:
        if lvl is String:
            _completed_levels.append(lvl)

    _deaths.clear()
    var deaths: Dictionary = DictionaryUtils.safe_getd(data, _DEATHS_KEY)
    for key: Variant in deaths:
        if key is String:
            var count: Variant = deaths[key]
            if count is int:
                _deaths[key] = count

    _best_times.clear()
    var times: Dictionary = DictionaryUtils.safe_getd(data, _TIMES_KEY)
    for key: Variant in times:
        if key is String:
            var time: Variant = times[key]
            if time is int:
                _best_times[key] = time
