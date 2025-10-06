extends AudioStreamPlayer


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("mute_music"):
        if playing:
            stop()
        else:
            play()
