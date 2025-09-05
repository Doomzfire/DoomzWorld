extends Area2D

var _player_inside: bool = false

@onready var panel: Panel = $"../UI/ChestPanel"
@onready var stash_vbox: VBoxContainer = $"../UI/ChestPanel/HBox/StashVBox"
@onready var loadout_vbox: VBoxContainer = $"../UI/ChestPanel/HBox/LoadoutVBox"
@onready var clear_btn: Button = $"../UI/ChestPanel/Buttons/ClearBtn"
@onready var close_btn: Button = $"../UI/ChestPanel/Buttons/CloseBtn"
@onready var hint_label: Label = $"../UI/HintLabel"

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    if clear_btn:
        clear_btn.pressed.connect(_on_clear_pressed)
    if close_btn:
        close_btn.pressed.connect(_toggle_panel)

func _process(_delta: float) -> void:
    if _player_inside and Input.is_action_just_pressed("interact"):
        _toggle_panel()

func _toggle_panel() -> void:
    if not panel:
        return
    panel.visible = not panel.visible
    if panel.visible:
        _rebuild_lists()
        if hint_label:
            hint_label.text = "Coffre ouvert: clique +/− pour préparer ton loadout"
    else:
        if hint_label:
            hint_label.text = "Appuie E près du coffre pour l'ouvrir"

func _rebuild_lists() -> void:
    for c in stash_vbox.get_children():
        c.queue_free()
    for c in loadout_vbox.get_children():
        c.queue_free()
    var gs: Node = get_node("/root/GameState")
    var stash: Dictionary = gs.load_stash()
    var loadout: Dictionary = gs.pre_run_loadout

    if stash.is_empty():
        var l := Label.new()
        l.text = "Stash vide"
        stash_vbox.add_child(l)
    else:
        for k in stash.keys():
            var key: String = str(k)
            var total: int = int(stash[key])
            var reserved: int = int(loadout.get(key, 0))
            var avail: int = max(total - reserved, 0)
            var hb := HBoxContainer.new()
            var lbl := Label.new()
            lbl.text = "%s  | Stash: %d  | Dispo: %d" % [key, total, avail]
            var add_btn := Button.new()
            add_btn.text = "+"
            add_btn.disabled = avail <= 0
            add_btn.pressed.connect(_on_add_pressed.bind(key))
            hb.add_child(lbl)
            hb.add_child(add_btn)
            stash_vbox.add_child(hb)

    if loadout.is_empty():
        var l2 := Label.new()
        l2.text = "Loadout vide"
        loadout_vbox.add_child(l2)
    else:
        for k2 in loadout.keys():
            var key2: String = str(k2)
            var qty2: int = int(loadout[key2])
            var hb2 := HBoxContainer.new()
            var lbl2 := Label.new()
            lbl2.text = "%s  | x%d" % [key2, qty2]
            var rem_btn := Button.new()
            rem_btn.text = "−"
            rem_btn.pressed.connect(_on_remove_pressed.bind(key2))
            hb2.add_child(lbl2)
            hb2.add_child(rem_btn)
            loadout_vbox.add_child(hb2)

func _on_add_pressed(item_id: String) -> void:
    var gs: Node = get_node("/root/GameState")
    var stash: Dictionary = gs.load_stash()
    var loadout: Dictionary = gs.pre_run_loadout
    var total: int = int(stash.get(item_id, 0))
    var current: int = int(loadout.get(item_id, 0))
    if current < total:
        loadout[item_id] = current + 1
        gs.pre_run_loadout = loadout
    _rebuild_lists()

func _on_remove_pressed(item_id: String) -> void:
    var gs: Node = get_node("/root/GameState")
    var loadout: Dictionary = gs.pre_run_loadout
    if loadout.has(item_id):
        var cur: int = int(loadout[item_id]) - 1
        if cur <= 0:
            loadout.erase(item_id)
        else:
            loadout[item_id] = cur
        gs.pre_run_loadout = loadout
    _rebuild_lists()

func _on_clear_pressed() -> void:
    var gs: Node = get_node("/root/GameState")
    gs.pre_run_loadout = {}
    _rebuild_lists()

func _on_body_entered(body: Node) -> void:
    if body.is_in_group("player"):
        _player_inside = true
        if hint_label:
            hint_label.text = "Coffre: appuie E pour l'ouvrir"

func _on_body_exited(body: Node) -> void:
    if body.is_in_group("player"):
        _player_inside = false
        if hint_label:
            hint_label.text = "WASD/Shift. Portail violet = E pour partir."
