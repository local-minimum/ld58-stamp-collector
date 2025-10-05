extends Node
class_name LevelsManager

enum Phase { IDLE, LOADING_PACKED_SCENE, SWAPPING_ROOT, SWAPPING_COMPLETE }

var _phase: Phase = Phase.IDLE
var _loading_resource_path: String
var _scene_idx: int = -1

var has_previous: bool:
    get():
        return _scene_idx > 0

var has_next: bool:
    get():
        return _scene_idx + 1 < scenes.size()

var level_id: String:
    get():
        if _scene_idx >= 0 && _scene_idx < level_ids.size():
            return level_ids[_scene_idx]
        return ""

func get_level_id(idx: int) -> String:
    if idx < 0 || idx >= level_ids.size():
        return ""
    return level_ids[idx]

@export var scenes: Array[String]
@export var menu_scene: String = "menu"
@export var outro_scene: String = "outro"
@export var level_ids: Array[String]
@export var level_names: Array[String]

var level_name: String:
    get():
        if _scene_idx >= 0 && _scene_idx < level_names.size():
            return level_names[_scene_idx]
        return ""

func _ready() -> void:
    if __SignalBus.on_scene_transition_new_scene_ready.connect(_handle_new_scene_ready) != OK:
        push_error("Failed to connect new scene ready")

func _process(_delta: float) -> void:
    match _phase:
        Phase.LOADING_PACKED_SCENE:
            _check_loading_next_scene()
        Phase.SWAPPING_COMPLETE:
            __SignalBus.on_scene_transition_complete.emit()
            _reset_phase()

func _handle_new_scene_ready() -> void:
    _phase = Phase.SWAPPING_COMPLETE

func transition_to_scene(idx: int) -> bool:
    if _phase != Phase.IDLE:
        return false
    _scene_idx = idx
    return _load_scene()

func transition_to_next_scene() -> bool:
    if _phase != Phase.IDLE:
        return false

    _scene_idx += 1
    return _load_scene()

func transition_to_previous_scene() -> bool:
    if _phase != Phase.IDLE:
        return false

    _scene_idx = maxi(-1, _scene_idx - 1)
    return _load_scene()

func transition_to_menu() -> void:
    _scene_idx = -1
    _load_scene()

func _load_scene() -> bool:
    if _scene_idx < 0:
        _scene_idx = -1
        _loading_resource_path = menu_scene
    elif _scene_idx >= scenes.size():
        _scene_idx = -1
        _loading_resource_path = outro_scene
    else:
        _loading_resource_path = scenes[_scene_idx]

    __SignalBus.on_scene_transition_initiate.emit()

    if ResourceLoader.load_threaded_request(_loading_resource_path, "PackedScene") != OK:
        push_error("Failed to initiate root swapping to '%s'" % _loading_resource_path)
        _handle_fail_and_reset()
        return false

    print_debug("[SceneSwapper] Loading packed scene")
    _phase = Phase.LOADING_PACKED_SCENE
    return true

func _check_loading_next_scene() -> void:
    var progress: Array = []

    match ResourceLoader.load_threaded_get_status(_loading_resource_path, progress):
        ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
            if progress.size() == 1:
                __SignalBus.on_scene_transition_progress.emit(progress[0])
        ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
            print_debug("[SceneSwapper] Packed scene loaded")
            var scene: PackedScene = ResourceLoader.load_threaded_get(_loading_resource_path)
            _phase = Phase.SWAPPING_ROOT
            match get_tree().change_scene_to_packed(scene):
                OK:
                    _phase = Phase.SWAPPING_COMPLETE
                    __SignalBus.on_scene_transition_progress.emit(1.0)
                ERR_CANT_CREATE:
                    push_error("Cannot create new root scene '%s'" % _loading_resource_path)
                    _handle_fail_and_reset()
                ERR_INVALID_PARAMETER:
                    push_error("Invalid parameter swapping root to packed scene '%s'" % _loading_resource_path)
                    _handle_fail_and_reset()

        ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
            push_error("Loading scene '%s', thread failed" % _loading_resource_path)
            _handle_fail_and_reset()
        ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
            push_error("Loading scene '%s', failed due to invalid resource" % _loading_resource_path)
            _handle_fail_and_reset()

func _handle_fail_and_reset() -> void:
    __SignalBus.on_scene_transition_fail.emit()
    _reset_phase()

func _reset_phase() -> void:
    _loading_resource_path = ""
    _phase = Phase.IDLE
