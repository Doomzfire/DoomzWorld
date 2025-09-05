extends Node2D

@onready var stash_label: Label = $UI/StashLabel

func _ready() -> void:
    _refresh_stash()

func _refresh_stash() -> void:
    var gs: Node = get_node("/root/GameState")
    var stash: Dictionary = gs.load_stash()
    if not stash_label:
        return
    if stash.is_empty():
        stash_label.text = "Stash: (vide)"
        return
    var pieces: Array[String] = []
    for k in stash.keys():
        var key: String = str(k)
        var name_fr: String = key
        if key == "branch":
            name_fr = "Branche"
        elif key == "flint":
            name_fr = "Silex"
        elif key == "bandage":
            name_fr = "Bandage"
        var qty: int = int(stash[key])
        pieces.append("%s x%d" % [name_fr, qty])
    stash_label.text = "Stash: " + ", ".join(pieces)
