extends CharacterBody2D

@export var move_speed: float = 160.0
@export var sprint_speed: float = 240.0
@export var accel: float = 12.0

@export var stamina_max: float = 100.0
var stamina: float = 100.0
@export var stamina_drain: float = 20.0
@export var stamina_regen: float = 12.0

@export var max_health: int = 100
var health: int = 100

var input_vector: Vector2 = Vector2.ZERO
@onready var stamina_bar: TextureProgressBar = get_tree().current_scene.get_node_or_null("UI/StaminaBar")
@onready var health_bar: TextureProgressBar = get_tree().current_scene.get_node_or_null("UI/HealthBar")

# --- Melee attack ---
@export var attack_range: float = 52.0
@export var attack_arc_deg: float = 80.0
@export var attack_damage: int = 15
@export var attack_cooldown: float = 0.45
var _atk_cd: float = 0.0

func _physics_process(delta: float) -> void:
    var dir: Vector2 = Vector2(
        Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
        Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    )
    input_vector = dir.normalized()

    var target_speed: float = move_speed
    var is_moving: bool = input_vector.length() > 0.0
    var is_sprinting: bool = Input.is_action_pressed("sprint") and stamina > 0.1 and is_moving

    if is_sprinting:
        target_speed = sprint_speed
        stamina = max(stamina - stamina_drain * delta, 0.0)
    else:
        stamina = min(stamina + stamina_regen * delta, stamina_max)

    var desired_velocity: Vector2 = input_vector * target_speed
    velocity = velocity.lerp(desired_velocity, clamp(accel * delta, 0.0, 1.0))
    move_and_slide()

    if stamina_bar:
        stamina_bar.max_value = stamina_max
        stamina_bar.value = stamina
    if health_bar:
        health_bar.max_value = max_health
        health_bar.value = health

func _process(delta: float) -> void:
    _atk_cd = max(_atk_cd - delta, 0.0)
    if Input.is_action_just_pressed("attack") and _atk_cd <= 0.0:
        _do_attack()
        _atk_cd = attack_cooldown

func _do_attack() -> void:
    var enemies: Array = get_tree().get_nodes_in_group("enemy")
    var mouse_pos: Vector2 = get_global_mouse_position()
    var dir_to_mouse: Vector2 = (mouse_pos - global_position).normalized()
    var half_arc: float = deg_to_rad(attack_arc_deg * 0.5)
    for e in enemies:
        if not (e is Node2D):
            continue
        var target: Node2D = e
        var to_e: Vector2 = target.global_position - global_position
        var dist: float = to_e.length()
        if dist > attack_range:
            continue
        var ang: float = dir_to_mouse.angle_to(to_e.normalized())
        if abs(ang) <= half_arc:
            if "take_damage" in e:
                e.take_damage(attack_damage)

func apply_damage(amount: int) -> void:
    health = max(health - amount, 0)
    if health_bar:
        health_bar.max_value = max_health
        health_bar.value = health
    if health <= 0:
        var gs: Node = get_node("/root/GameState")
        gs.reset_run_inventory()
        get_tree().change_scene_to_file("res://scenes/Lobby.tscn")
