extends Area2D

@export var item_id: String = "branch"
@export var quantity: int = 1

var _player_inside: bool = false
@onready var hint_label: Label = $"../UI/HintLabel"
@onready var run_label: Label = $"../UI/RunInvLabel"

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
    if _player_inside and Input.is_action_just_pressed("interact"):
        var gs: Node = get_node("/root/GameState")
        gs.add_run_item(item_id, quantity)
        if run_label:
            var inv: Dictionary = gs.get_run_inventory()
            var txt: String = "Run: (vide)"
            if not inv.is_empty():
                var parts: Array[String] = []
                for k in inv.keys():
                    var key: String = str(k)
                    parts.append("%s x%d" % [key, int(inv[key])])
                txt = "Run: " + ", ".join(parts)
            run_label.text = txt
        queue_free()

func _on_body_entered(body: Node) -> void:
    if body.is_in_group("player"):
        _player_inside = true
        if hint_label:
            hint_label.text = "E: Ramasser %s x%d" % [item_id, quantity]

func _on_body_exited(body: Node) -> void:
    if body.is_in_group("player"):
        _player_inside = false
