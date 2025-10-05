extends Node3D

@export var cam_node: Node3D
@export var max_distance: float = 100

func _process(_delta: float) -> void:
    var v: Vector3 = global_position - cam_node.global_position
    if v.length() > max_distance:
        v = v.normalized() * max_distance
        global_position = cam_node.global_position + v
