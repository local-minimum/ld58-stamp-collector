extends Node

@export var current: Label
@export var highscore: Label

var _level: Level

func _enter_tree() -> void:
    if __SignalBus.on_update_level_stats.connect(_handle_level_stats_update) != OK:
        push_error("Failed to connect update level stats")

    if __SignalBus.on_start_run.connect(_handle_run_started) != OK:
        push_error("Failed to connect run started")

    if __SignalBus.on_player_death.connect(_handle_player_death) != OK:
        push_error("Failed to connect player death")

    if __SignalBus.on_level_completed.connect(_handle_level_completed) != OK:
        push_error("Failed to connect level completed")

    if __SignalBus.on_resume_play.connect(_handle_resume_play) != OK:
        push_error("Failed to connect resume play")

func _handle_level_stats_update(level: Level, _is_update: bool) -> void:
    _level = level
    current.text = ("%.3fs" % (level.current_time_msec / 1000.0)) if level.current_time_msec >= 0 else "%.3f" % 0.0
    highscore.text = ("%.3fs" % (level.best_time_msec / 1000.0)) if level.best_time_msec >= 0 else "Unbeaten"

var _start: int
var _running: bool

func _handle_run_started(start: int) -> void:
    _start = start
    _running = true

func _handle_player_death() -> void:
    _running = false

func _handle_level_completed(_goal: Goal, time: int) -> void:
    _running = false
    current.text = "%.3fs" % (time / 1000.0)
    if _level == null || _level.best_time_msec < 0 || time < _level.best_time_msec:
        highscore.text = current.text

func _process(_delta: float) -> void:
    if !_running || Engine.time_scale == 0:
        return

    current.text = "%.3fs" %  ((Time.get_ticks_msec() - _start)/ 1000.0)

func _handle_resume_play(pause: int) -> void:
    if _running:
        _start += pause
