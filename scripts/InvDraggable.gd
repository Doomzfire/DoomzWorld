extends Button
signal assign_requested(item_id: String)

var item_id: String = ""
var count: int = 0

func _ready() -> void:
    mouse_filter = MOUSE_FILTER_PASS

func _get_drag_data(_pos: Vector2) -> Variant:
    if item_id == "":
        return null
    var preview := Label.new()
    preview.text = "→ " + item_id
    set_drag_preview(preview)
    return {"type":"item","item_id": item_id}

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
    return false

func _drop_data(_pos: Vector2, data: Variant) -> void:
    pass

func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
        if item_id != "":
            emit_signal("assign_requested", item_id)
