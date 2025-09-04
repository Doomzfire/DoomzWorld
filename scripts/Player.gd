extends CharacterBody2D

@export var move_speed := 160.0
@export var sprint_speed := 240.0
@export var accel := 12.0

@export var stamina_max := 100.0
var stamina := 100.0
@export var stamina_drain := 20.0
@export var stamina_regen := 12.0

var input_vector := Vector2.ZERO
@onready var stamina_bar := get_tree().current_scene.get_node_or_null("UI/StaminaBar")

func _physics_process(delta: float) -> void:
    input_vector = Vector2(
        Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
        Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    ).normalized()

    var target_speed := move_speed
    var is_moving := input_vector.length() > 0.0
    var is_sprinting := Input.is_action_pressed("sprint") and stamina > 0.1 and is_moving

    if is_sprinting:
        target_speed = sprint_speed
        stamina = max(stamina - stamina_drain * delta, 0.0)
    else:
        stamina = min(stamina + stamina_regen * delta, stamina_max)

    var desired_velocity := input_vector * target_speed
    velocity = velocity.lerp(desired_velocity, clamp(accel * delta, 0.0, 1.0))
    move_and_slide()

    if stamina_bar:
        stamina_bar.max_value = stamina_max
        stamina_bar.value = stamina
