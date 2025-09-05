extends Node

var player_id: String = ""
var run_seed: int = 0
var temp_run_inventory: Dictionary = {}
var pre_run_loadout: Dictionary = {}

const SAVE_DIR: String = "user://players"
const ID_FILE: String = "user://players/player_id.json"

func _ready() -> void:
    _ensure_player_id()

func _ensure_player_id() -> void:
    DirAccess.make_dir_recursive_absolute(SAVE_DIR)
    if FileAccess.file_exists(ID_FILE):
        var f: FileAccess = FileAccess.open(ID_FILE, FileAccess.READ)
        var text: String = f.get_as_text()
        var data: Variant = JSON.parse_string(text)
        if typeof(data) == TYPE_DICTIONARY:
            var dict: Dictionary = data
            if dict.has("player_id"):
                player_id = str(dict["player_id"])
                return
    player_id = _make_simple_id()
    var out: Dictionary = {"player_id": player_id, "created_at": Time.get_datetime_string_from_system()}
    var fw: FileAccess = FileAccess.open(ID_FILE, FileAccess.WRITE)
    fw.store_string(JSON.stringify(out))

func _make_simple_id() -> String:
    var rng: RandomNumberGenerator = RandomNumberGenerator.new()
    rng.randomize()
    var parts: Array[String] = []
    for i in range(5):
        parts.append(str(rng.randi()))
    return "%s-%s-%s-%s-%s" % [parts[0], parts[1], parts[2], parts[3], parts[4]]

func start_run() -> void:
    var rng: RandomNumberGenerator = RandomNumberGenerator.new()
    rng.randomize()
    run_seed = int(rng.randi())
    reset_run_inventory()
    # appliquer le loadout (déplacer du stash -> inventaire de run)
    var loadout: Dictionary = pre_run_loadout.duplicate()
    if not loadout.is_empty():
        var stash: Dictionary = load_stash()
        for k in loadout.keys():
            var key: String = str(k)
            var want: int = int(loadout[key])
            var have: int = int(stash.get(key, 0))
            var take: int = min(want, have)
            if take > 0:
                stash[key] = have - take
                if int(stash[key]) <= 0:
                    stash.erase(key)
                add_run_item(key, take)
        save_stash(stash)
    pre_run_loadout = {}
    get_tree().change_scene_to_file("res://scenes/Run.tscn")

func finish_run() -> void:
    _merge_run_into_stash()
    reset_run_inventory()
    get_tree().change_scene_to_file("res://scenes/Lobby.tscn")

func reset_run_inventory() -> void:
    temp_run_inventory = {}

func add_run_item(item_id: String, qty: int) -> void:
    var current: int = 0
    if temp_run_inventory.has(item_id):
        current = int(temp_run_inventory[item_id])
    temp_run_inventory[item_id] = current + qty

func consume_run_item(item_id: String, qty: int) -> bool:
    if not temp_run_inventory.has(item_id):
        return false
    var cur: int = int(temp_run_inventory[item_id])
    if cur < qty:
        return false
    cur -= qty
    if cur <= 0:
        temp_run_inventory.erase(item_id)
    else:
        temp_run_inventory[item_id] = cur
    return true

func get_run_inventory() -> Dictionary:
    return temp_run_inventory.duplicate()

func _player_dir() -> String:
    return SAVE_DIR + "/" + player_id

func _stash_path() -> String:
    return _player_dir() + "/stash.json"

func load_stash() -> Dictionary:
    var dir_path: String = _player_dir()
    DirAccess.make_dir_recursive_absolute(dir_path)
    var p: String = _stash_path()
    if FileAccess.file_exists(p):
        var f: FileAccess = FileAccess.open(p, FileAccess.READ)
        var data: Variant = JSON.parse_string(f.get_as_text())
        if typeof(data) == TYPE_DICTIONARY:
            return data
    return {}

func save_stash(stash: Dictionary) -> void:
    var dir_path: String = _player_dir()
    DirAccess.make_dir_recursive_absolute(dir_path)
    var fw: FileAccess = FileAccess.open(_stash_path(), FileAccess.WRITE)
    fw.store_string(JSON.stringify(stash))

func _merge_run_into_stash() -> void:
    var stash: Dictionary = load_stash()
    for k in temp_run_inventory.keys():
        var key: String = str(k)
        var add: int = int(temp_run_inventory[key])
        var cur: int = 0
        if stash.has(key):
            cur = int(stash[key])
        stash[key] = cur + add
    save_stash(stash)

func run_inv_to_string() -> String:
    if temp_run_inventory.is_empty():
        return "Run: (vide)"
    var pieces: Array[String] = []
    for k in temp_run_inventory.keys():
        var key: String = str(k)
        pieces.append("%s x%d" % [key, int(temp_run_inventory[key])])
    return "Run: " + ", ".join(pieces)

func stash_to_string() -> String:
    var stash: Dictionary = load_stash()
    if stash.is_empty():
        return "Stash: (vide)"
    var pieces: Array[String] = []
    for k in stash.keys():
        var key: String = str(k)
        pieces.append("%s x%d" % [key, int(stash[key])])
    return "Stash: " + ", ".join(pieces)
