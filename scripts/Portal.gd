extends Area2D

@export var hold_time := 1.2
var _timer := 0.0
var _player_inside := false

@onready var label := $"../UI/HintLabel"

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
    if not _player_inside:
        _timer = 0.0
        return

    if Input.is_action_pressed("interact"):
        _timer += _delta
        if label:
            label.text = "Portail: " + str(snappedf(hold_time - _timer, 0.1)) + "s"
        if _timer >= hold_time:
            if label:
                label.text = "Expédition en cours..."
            var gs := get_node("/root/GameState")
            gs.start_run()
            _timer = 0.0
    else:
        if label:
            label.text = "Appuie et maintiens E pour entrer dans le portail"
        _timer = 0.0

func _on_body_entered(body: Node) -> void:
    if body.is_in_group("player"):
        _player_inside = true
        if label:
            label.text = "Portail violet: maintiens E pour partir"

func _on_body_exited(body: Node) -> void:
    if body.is_in_group("player"):
        _player_inside = false
        _timer = 0.0
        if label:
            label.text = "WASD pour bouger, Shift pour sprinter. E = action"
