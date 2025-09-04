extends Area2D

@export var hold_time := 2.0
var _timer := 0.0
var _player_inside := false

signal extracted

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
    if not _player_inside:
        _timer = 0.0
        return

    if Input.is_action_pressed("interact"):
        _timer += delta
        if _timer >= hold_time:
            emit_signal("extracted")
            _timer = 0.0
    else:
        _timer = 0.0

func _on_body_entered(body: Node) -> void:
    if body.is_in_group("player"):
        _player_inside = true

func _on_body_exited(body: Node) -> void:
    if body.is_in_group("player"):
        _player_inside = false
        _timer = 0.0
