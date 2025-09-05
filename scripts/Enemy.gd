extends CharacterBody2D

@export var move_speed := 70.0
@export var damage := 10
@export var hit_cooldown := 0.8
var _cool: float = 0.0

func _physics_process(delta: float) -> void:
    _cool = max(_cool - delta, 0.0)
    var player := get_tree().current_scene.get_node_or_null("Player")
    var dir := Vector2.ZERO
    if player and (global_position.distance_to(player.global_position) < 380.0):
        dir = (player.global_position - global_position).normalized()
    else:
        var noise := Vector2(sin(Time.get_ticks_msec() / 900.0 + get_instance_id()), cos(Time.get_ticks_msec() / 1100.0 + get_instance_id()))
        dir = noise.normalized()
    velocity = dir * move_speed
    move_and_slide()

    if player and _cool <= 0.0 and global_position.distance_to(player.global_position) < 24.0:
        if "apply_damage" in player:
            player.apply_damage(damage)
            _cool = hit_cooldown
