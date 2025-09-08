extends Button
signal dropped(index: int, item_id: String)
signal clear_requested(index: int)

@export var index: int = 0

func _get_drag_data(_pos: Vector2) -> Variant:
    if tooltip_text == "" or tooltip_text == null:
        return null
    var preview := Label.new()
    preview.text = "→ " + tooltip_text
    set_drag_preview(preview)
    return {"type":"item","item_id": String(tooltip_text)}

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
    return typeof(data) == TYPE_DICTIONARY and data.has("type") and data["type"] == "item" and data.has("item_id")

func _drop_data(_pos: Vector2, data: Variant) -> void:
    if _can_drop_data(_pos, data):
        emit_signal("dropped", index, String(data["item_id"]))

func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
        emit_signal("clear_requested", index)
