extends CanvasLayer

# --- NODES ---
@onready var inventory_panel: Panel = $InventoryPanel
@onready var item_context_menu: Control = $ItemContextMenu

# --- PLAYER REFERENCE ---
var player: Node = null

# ----------------------------
# SETUP PLAYER
# ----------------------------
func set_player(p: Node) -> void:
	player = p
	# Transmettre les références HUD au Player pour interaction
	player.set_hud(self)

# ----------------------------
# CLOSE CONTEXT MENU ON OUTSIDE CLICK
# ----------------------------
func _unhandled_input(event: InputEvent) -> void:
	if item_context_menu.visible:
		if event is InputEventMouseButton and event.pressed:
			var menu_rect: Rect2 = item_context_menu.get_global_rect()
			if not menu_rect.has_point(event.position):
				item_context_menu.visible = false
