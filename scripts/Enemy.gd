
extends CharacterBody2D

@export var move_speed := 70.0
@export var touch_damage := 10
@export var hit_cooldown := 0.8
var _touch_cd: float = 0.0

@export var max_health := 30
var health: int = 30

@export var loot_drop_chance := 0.5
@export var loot_rare_chance := 0.15

@onready var hpbar: TextureProgressBar = get_node_or_null("HP")

func _ready() -> void:
    add_to_group("enemy")
    health = max_health
    if hpbar:
        hpbar.max_value = max_health
        hpbar.value = health

func _physics_process(delta: float) -> void:
    _touch_cd = max(_touch_cd - delta, 0.0)
    var player := get_tree().current_scene.get_node_or_null("Player")
    var dir := Vector2.ZERO
    if player and (global_position.distance_to(player.global_position) < 380.0):
        dir = (player.global_position - global_position).normalized()
    else:
        var noise := Vector2(sin(Time.get_ticks_msec() / 900.0 + get_instance_id()), cos(Time.get_ticks_msec() / 1100.0 + get_instance_id()))
        dir = noise.normalized()
    velocity = dir * move_speed
    move_and_slide()

    if player and _touch_cd <= 0.0 and global_position.distance_to(player.global_position) < 24.0:
        if "apply_damage" in player:
            player.apply_damage(touch_damage)
            _touch_cd = hit_cooldown

func take_damage(amount: int) -> void:
    health = max(health - amount, 0)
    if hpbar:
        hpbar.value = health
    if health <= 0:
        _die()

func _die() -> void:
    _maybe_drop_loot()
    queue_free()

func _maybe_drop_loot() -> void:
    var rng := RandomNumberGenerator.new()
    rng.randomize()
    if rng.randf() > loot_drop_chance:
        return
    var id := "branch"
    var r := rng.randf()
    if r > (1.0 - loot_rare_chance):
        id = "bandage"
    elif r > 0.5:
        id = "flint"
    var item := Area2D.new()
    item.name = "ItemPickup"
    item.script = load("res://scripts/ItemPickup.gd")
    item.position = global_position
    var col := CollisionShape2D.new()
    var shape := CircleShape2D.new()
    shape.radius = 12.0
    col.shape = shape
    var spr := Sprite2D.new()
    var itemdb := get_node("/root/ItemDB")
    var def: Dictionary = itemdb.get_def(id)
    var tex_path: String = String(def.get("icon", ""))
    if tex_path != "":
        spr.texture = load(tex_path)
    spr.centered = true
    item.add_child(spr)
    item.add_child(col)
    get_tree().current_scene.add_child(item)
    item.set("item_id", id)
    item.set("quantity", 1)
