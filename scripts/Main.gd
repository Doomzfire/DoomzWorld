extends Node2D

@onready var hint_label := $UI/HintLabel

func _ready() -> void:
    _ensure_input()
    var zone := $ExtractZone
    if zone:
        zone.extracted.connect(_on_extracted)

func _on_extracted() -> void:
    if hint_label:
        hint_label.text = "Extraction réussie ! (Étape 2: sauvegarde du loot)"
    print("Extraction réussie ! (Étape 2 : sauvegarder le loot ici)")

func _ensure_input() -> void:
    var mapping: Dictionary = {
        "ui_up": KEY_W,
        "ui_down": KEY_S,
        "ui_left": KEY_A,
        "ui_right": KEY_D,
        "sprint": KEY_SHIFT,
        "interact": KEY_E
    }
    for action in mapping.keys():
        if not InputMap.has_action(action):
            InputMap.add_action(action)
        var exists := false
        for ev in InputMap.action_get_events(action):
            if ev is InputEventKey and ev.physical_keycode == mapping[action]:
                exists = true
                break
        if not exists:
            var e := InputEventKey.new()
            e.physical_keycode = mapping[action]
            InputMap.action_add_event(action, e)
