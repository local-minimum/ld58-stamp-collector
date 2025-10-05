extends Node
class_name SignalBus

@warning_ignore_start("unused_signal")
signal on_menu_show_level_info(level_idx: int)
signal on_menu_hide_level_info(level_idx: int)

signal on_ready_camera(cam: Camera3D)
signal on_update_level_stats(level: Level, is_update: bool)

signal on_start_run(start: int)
signal on_player_death()

signal on_set_required_stamps(stamps: int)
signal on_collect_stamp(stamp: CollectableStamp)
signal on_forgot_stamps(remaining: int)
signal on_level_completed(time: int)

signal on_scene_transition_initiate()
signal on_scene_transition_new_scene_ready()
signal on_scene_transition_complete()
signal on_scene_transition_fail()
signal on_scene_transition_progress(progress: float)

@warning_ignore_restore("unused_signal")
