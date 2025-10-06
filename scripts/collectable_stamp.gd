extends Node3D
class_name CollectableStamp

static var _next_sound: int

@export var anim: AnimationPlayer
@export var stamp: Node3D
@export var delayed_removal: float = 0.45
@export var speaker: AudioStreamPlayer
@export var clips: Array[AudioStream]
@export var pause_between_sounds_msec: int = 400

var _collected: bool

func _ready() -> void:
    anim.play("Default")
    if __SignalBus.on_player_death.connect(_handle_death) != OK:
        push_error("Failed to connect player death")


func _handle_death() -> void:
    _collected = false
    stamp.visible = true

func _on_body_entered(body:Node3D) -> void:
    if _collected:
        return

    if body is BallController:
        _collected = true
        __SignalBus.on_collect_stamp.emit(self)

        clips.shuffle()
        _queue_play(clips[0])

        await get_tree().create_timer(delayed_removal).timeout
        stamp.visible = false


func _queue_play(sound: AudioStream) -> void:
    if Time.get_ticks_msec() < _next_sound:
        print_debug("[Stamp] waiting because still playing")
        await get_tree().create_timer((Time.get_ticks_msec() - _next_sound) / 1000.0).timeout

    _next_sound = ceili(sound.get_length() * 1000) + Time.get_ticks_msec() + pause_between_sounds_msec
    speaker.stream = sound
    speaker.play()
