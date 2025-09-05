extends Area2D

@export var hold_time := 2.0
var _timer := 0.0
var _player_inside := false
@onready var label := $"../UI/HintLabel"

signal extracted

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
            label.text = "Extraction: " + str(snappedf(hold_time - _timer, 0.1)) + "s"
        if _timer >= hold_time:
            emit_signal("extracted")
            _timer = 0.0
    else:
        if label:
            label.text = "Maintiens E pour t'extraire"
        _timer = 0.0

func _on_body_entered(body: Node) -> void:
    if body.is_in_group("player"):
        _player_inside = true
        if label:
            label.text = "Maintiens E pour t'extraire"

func _on_body_exited(body: Node) -> void:
    if body.is_in_group("player"):
        _player_inside = false
        _timer = 0.0
        if label:
            label.text = "Explore et trouve la zone orange pour t'extraire"
