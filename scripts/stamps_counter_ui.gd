extends Label

var _requireed: int
var _collected_stamps: Array[CollectableStamp]

func _enter_tree() -> void:
    if __SignalBus.on_player_death.connect(_clear_progress) != OK:
        push_error("Failed to connect player death")

    if __SignalBus.on_start_run.connect(_clear_progress) != OK:
        push_error("Failed to connect start run")

    if __SignalBus.on_collect_stamp.connect(_handle_collect_stamp) != OK:
        push_error("Failed to connect collect stamp")

    if __SignalBus.on_set_required_stamps.connect(_handle_set_required) != OK:
        push_error("Failed to connect set required stamps")

    _sync()

func _clear_progress() -> void:
    _collected_stamps.clear()
    _sync()

func _handle_set_required(stamps: int) -> void:
    _requireed = stamps
    _collected_stamps.clear()
    _sync()

func _handle_collect_stamp(stamp: CollectableStamp) -> void:
    if !_collected_stamps.has(stamp):
        _collected_stamps.append(stamp)

        _sync()

func _sync() -> void:
    text = "%s" % maxi(0, _requireed - _collected_stamps.size())
