extends Node2D

func _ready() -> void:
    _ensure_input()
    call_deferred("_go_to_lobby")

func _go_to_lobby() -> void:
    get_tree().change_scene_to_file("res://scenes/Lobby.tscn")

func _ensure_input() -> void:
    var mapping: Dictionary = {
        "ui_up": KEY_W,
        "ui_down": KEY_S,
        "ui_left": KEY_A,
        "ui_right": KEY_D,
        "sprint": KEY_SHIFT,
        "interact": KEY_E,
        "inventory": KEY_I,
        "hotbar_1": KEY_1,
        "hotbar_2": KEY_2,
        "hotbar_3": KEY_3,
        "hotbar_4": KEY_4,
        "hotbar_5": KEY_5,
        "attack": MOUSE_BUTTON_LEFT
    }
    for action in mapping.keys():
        if not InputMap.has_action(action):
            InputMap.add_action(action)

        if action == "attack":
            var has_mouse := false
            for ev in InputMap.action_get_events(action):
                if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
                    has_mouse = true
                    break
            if not has_mouse:
                var em := InputEventMouseButton.new()
                em.button_index = MOUSE_BUTTON_LEFT
                em.pressed = false
                InputMap.action_add_event(action, em)
            continue

        var exists := false
        for ev in InputMap.action_get_events(action):
            if ev is InputEventKey and ev.physical_keycode == mapping[action]:
                exists = true
                break
        if not exists:
            var e := InputEventKey.new()
            e.physical_keycode = mapping[action]
            InputMap.action_add_event(action, e)
