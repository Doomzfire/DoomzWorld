extends Node2D

@export var half_tiles_x := 2
@export var half_tiles_y := 2
@export var tile_size := Vector2i(512,512)
@export var loot_count := 14
@export var enemy_count := 6

@onready var run_label: Label = $UI/RunInvLabel
@onready var inv_panel: Panel = $UI/InventoryPanel
@onready var inv_grid: GridContainer = $UI/InventoryPanel/InvGrid
@onready var hotbar: HBoxContainer = $UI/Hotbar

var biome_tex_path: String = "res://assets/ground_grass.png"
var biome_name: String = "Prairie"


func _inv_to_str(inv: Dictionary) -> String:
    if inv.is_empty():
        return "Run: (vide)"
    var parts: Array[String] = []
    for k in inv.keys():
        var key: String = str(k)
        parts.append("%s x%d" % [key, int(inv[key])])
    return "Run: " + ", ".join(parts)

func _ready() -> void:
    _choose_biome()
    _build_ground()
    _place_extract_zone()
    _spawn_loot()
    _spawn_enemies()
    var zone := $ExtractZone
    if zone:
        zone.extracted.connect(_on_extracted)
        zone.z_index = 5
    if has_node("Player"):
        $Player.z_index = 10
    var gs: Node = get_node("/root/GameState")
    if run_label:
        run_label.text = _inv_to_str(gs.get_run_inventory())
    _rebuild_inventory_ui()
    _rebuild_hotbar()

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("inventory"):
        inv_panel.visible = not inv_panel.visible
    for i in range(1,6):
        var action := "hotbar_%d" % i
        if Input.is_action_just_pressed(action):
            _use_hotbar_index(i-1)

func _choose_biome() -> void:
    var rng := RandomNumberGenerator.new()
    rng.randomize()
    var roll := rng.randi() % 4
    if roll == 0:
        biome_tex_path = "res://assets/ground_grass.png"; biome_name = "Prairie"
    elif roll == 1:
        biome_tex_path = "res://assets/ground_sand.png"; biome_name = "Sable"
    elif roll == 2:
        biome_tex_path = "res://assets/ground_snow.png"; biome_name = "Neige"
    else:
        biome_tex_path = "res://assets/ground_dirt.png"; biome_name = "Terre"

func _build_ground() -> void:
    var tex := load(biome_tex_path)
    var ground := Node2D.new()
    ground.name = "Ground"
    add_child(ground)
    move_child(ground, 0)
    ground.z_index = -100
    var rng := RandomNumberGenerator.new()
    rng.randomize()
    for y in range(-half_tiles_y, half_tiles_y+1):
        for x in range(-half_tiles_x, half_tiles_x+1):
            var s := Sprite2D.new()
            s.texture = tex
            s.position = Vector2(x * tile_size.x, y * tile_size.y)
            s.rotation_degrees = float(rng.randi() % 4) * 90.0
            ground.add_child(s)

func _place_extract_zone() -> void:
    var zone := $ExtractZone
    if not zone:
        return
    var bounds_x := (half_tiles_x) * tile_size.x
    var bounds_y := (half_tiles_y) * tile_size.y
    var rng := RandomNumberGenerator.new()
    rng.randomize()
    var rx := rng.randf_range(-bounds_x * 0.8, bounds_x * 0.8)
    var ry := rng.randf_range(-bounds_y * 0.8, bounds_y * 0.8)
    zone.position = Vector2(rx, ry)

func _spawn_loot() -> void:
    var rng := RandomNumberGenerator.new()
    rng.randomize()
    for i in range(loot_count):
        var roll := rng.randf()
        var id: String = "branch"
        if roll > 0.65:
            id = "flint"
        if roll > 0.9:
            id = "bandage"
        var px := rng.randf_range(-half_tiles_x * tile_size.x * 0.9, half_tiles_x * tile_size.x * 0.9)
        var py := rng.randf_range(-half_tiles_y * tile_size.y * 0.9, half_tiles_y * tile_size.y * 0.9)
        _spawn_item(id, Vector2(px, py))

func _spawn_item(id: String, pos: Vector2) -> void:
    var item := Area2D.new()
    item.name = "ItemPickup"
    item.script = load("res://scripts/ItemPickup.gd")
    item.position = pos
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
    add_child(item)
    item.set("item_id", id)
    item.set("quantity", 1)

func _spawn_enemies() -> void:
    var rng := RandomNumberGenerator.new()
    rng.randomize()
    for i in range(enemy_count):
        var e := CharacterBody2D.new()
        e.name = "Enemy"
        e.script = load("res://scripts/Enemy.gd")
        var spr := Sprite2D.new()
        spr.texture = load("res://assets/slime.png")
        spr.centered = true
        e.add_child(spr)
        e.position = Vector2(
            rng.randf_range(-half_tiles_x * tile_size.x * 0.8, half_tiles_x * tile_size.x * 0.8),
            rng.randf_range(-half_tiles_y * tile_size.y * 0.8, half_tiles_y * tile_size.y * 0.8)
        )
        add_child(e)

func _rebuild_inventory_ui() -> void:
    for c in inv_grid.get_children():
        c.queue_free()
    var gs := get_node("/root/GameState")
    var inv: Dictionary = gs.get_run_inventory()
    for k in inv.keys():
        var key: String = str(k)
        var count: int = int(inv[key])
        var itemdb := get_node("/root/ItemDB")
        var def: Dictionary = itemdb.get_def(key)
        var btn := Button.new()
        var name_s: String = String(def.get("name", String(key)))
        btn.text = "%s x%d" % [name_s, count]
        var icon_path: String = String(def.get("icon", ""))
        if icon_path != "":
            btn.icon = load(icon_path)
        btn.disabled = true
        inv_grid.add_child(btn)

func _rebuild_hotbar() -> void:
    for c in hotbar.get_children():
        c.queue_free()
    var gs := get_node("/root/GameState")
    var inv: Dictionary = gs.get_run_inventory()
    var ids: Array = inv.keys()
    for i in range(5):
        var slot := Button.new()
        slot.text = str(i+1)
        slot.disabled = true
        slot.custom_minimum_size = Vector2(120,28)
        if i < ids.size():
            var key: String = str(ids[i])
            var itemdb := get_node("/root/ItemDB")
            var def: Dictionary = itemdb.get_def(key)
            var name_s2: String = String(def.get("name", String(key)))
            slot.text = "%d) %s x%d" % [i+1, name_s2, int(inv[key])]
            var icon_path: String = String(def.get("icon", ""))
            if icon_path != "":
                slot.icon = load(icon_path)
            slot.hint_tooltip = key
        hotbar.add_child(slot)

func _use_hotbar_index(index: int) -> void:
    var gs := get_node("/root/GameState")
    var inv: Dictionary = gs.get_run_inventory()
    var ids: Array = inv.keys()
    if index < 0 or index >= ids.size():
        return
    var key: String = str(ids[index])
    var itemdb := get_node("/root/ItemDB")
    var def: Dictionary = itemdb.get_def(key)
    var heal: int = int(def.get("use_heal", 0))
    if heal > 0:
        if gs.consume_run_item(key, 1):
            var player := $Player
            if player and "health" in player:
                player.health = min(player.max_health, player.health + heal)
                var hb := get_tree().current_scene.get_node_or_null("UI/HealthBar")
                if hb:
                    hb.value = player.health
            _rebuild_inventory_ui()
            _rebuild_hotbar()

func _on_extracted() -> void:
    var gs := get_node("/root/GameState")
    gs.finish_run()
