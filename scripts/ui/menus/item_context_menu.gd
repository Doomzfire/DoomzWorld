extends Control

# --- VARIABLES ---
var item: Resource = null                 # Item actuellement sélectionné
var target_node: Node = null              # Slot ou node cliqué

# --- SIGNALS ---
signal use_item(item: Resource, target_node: Node)
signal drop_item(item: Resource, target_node: Node)

# ----------------------------
# READY
# ----------------------------
func _ready() -> void:
	# Récupérer les boutons "Use" et "Drop" dans le VBoxContainer
	var use_btn: Button = $VBoxContainer.get_child(0) as Button
	var drop_btn: Button = $VBoxContainer.get_child(1) as Button

	use_btn.text = "Use"
	drop_btn.text = "Drop"

	use_btn.pressed.connect(_on_use_pressed)
	drop_btn.pressed.connect(_on_drop_pressed)

	# Cacher le menu au départ
	visible = false

# ----------------------------
# SHOW MENU
# ----------------------------
func show_menu(pos: Vector2, clicked_item: Resource, clicked_node: Node) -> void:
	item = clicked_item
	target_node = clicked_node
	global_position = pos
	visible = true

# ----------------------------
# BUTTON ACTIONS
# ----------------------------
func _on_use_pressed() -> void:
	if item and target_node:
		emit_signal("use_item", item, target_node)
	visible = false

func _on_drop_pressed() -> void:
	if item and target_node:
		emit_signal("drop_item", item, target_node)
	visible = false
