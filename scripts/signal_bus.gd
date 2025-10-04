extends Node
class_name SignalBus

@warning_ignore_start("unused_signal")
signal on_ready_camera(cam: Camera3D)

signal on_start_run()
signal on_player_death()

signal on_set_required_stamps(stamps: int)
signal on_collect_stamp(stamp: CollectableStamp)
signal on_forgot_stamps(remaining: int)
signal on_level_completed()

@warning_ignore_restore("unused_signal")
