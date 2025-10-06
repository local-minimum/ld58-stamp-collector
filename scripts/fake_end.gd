extends CanvasLayer

@export var show_time: float = 2
@export var controller: BallController

func _ready() -> void:
    controller.cinematic = true

    await get_tree().create_timer(show_time).timeout

    hide()
    controller.cinematic = false
