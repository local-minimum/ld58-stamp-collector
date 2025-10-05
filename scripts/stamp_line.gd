extends Node3D

@export var speed: float = 1
@export var wrap_distance: float = 35

func _process(delta: float) -> void:
    for child: Node in get_children():
        if child is not Node3D:
            continue

        var n: Node3D = child
        n.position.z += speed * delta
        if absf(n.position.z * signf(speed)) > wrap_distance:
            var overshoot: float = absf(n.position.z - wrap_distance)
            var new_z: float = -(wrap_distance - overshoot) if speed > 0 else -(wrap_distance - overshoot)
            # print_debug("[Stamp Line] Wraping %s (speed %s) from %s -> %s" % [n.name, speed, n.position.z, new_z])
            n.position.z = new_z
