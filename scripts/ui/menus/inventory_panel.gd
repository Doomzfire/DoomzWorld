extends Panel

# --- EXPORTS ---
@export var slot_count: int = 25
@export var slot_size: Vector2 = Vector2(50, 50)
@export var columns: int = 5

# --- INVENTORY DATA ---
var slots: Array[Button] = []        # Liste des boutons représentant les slots
var items: Array[Resource] = []      # Items actuellement stockés

# ----------------------------
# READY
# ----------------------------
func _ready() -> void:
	var grid: GridContainer = $GridContainer
	grid.columns = columns

	# Créer les slots
	for i in range(slot_count):
		var btn: Button = Button.new()
		btn.text = ""
		btn.custom_minimum_size = slot_size
		btn.focus_mode = Control.FOCUS_NONE

		# Ajouter une icône centrée dans le bouton
		var icon: TextureRect = TextureRect.new()
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon.custom_minimum_size = slot_size
		btn.add_child(icon)

		# Connecter l'événement clic droit
		btn.connect("gui_input", Callable(self, "_on_slot_input").bind(btn))

		# Ajouter le bouton à la grille et à la liste des slots
		grid.add_child(btn)
		slots.append(btn)

# ----------------------------
# ADD ITEM TO INVENTORY
# ----------------------------
func add_item(item: Resource) -> void:
	if items.size() >= slot_count:
		print("⚠️ Inventory is full!")
		return

	items.append(item)
	var slot_index: int = items.size() - 1
	var btn: Button = slots[slot_index]

	# Remplir le slot avec l'icône et les infos
	var icon_rect: TextureRect = btn.get_child(0) as TextureRect
	icon_rect.texture = item.icon if item.icon else null

	btn.set_meta("item", item)
	btn.tooltip_text = "%s\n%s" % [item.name, item.description]

# ----------------------------
# REMOVE ITEM FROM INVENTORY
# ----------------------------
func remove_item(item: Resource) -> void:
	for i in range(items.size()):
		if items[i] == item:
			items.remove_at(i)
			var btn: Button = slots[i]
			btn.set_meta("item", null)
			var icon_rect: TextureRect = btn.get_child(0) as TextureRect
			icon_rect.texture = null
			btn.tooltip_text = ""
			return

# ----------------------------
# HANDLE RIGHT-CLICK ON SLOT
# ----------------------------
func _on_slot_input(event: InputEvent, btn: Button) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if btn.has_meta("item"):
			var item: Resource = btn.get_meta("item")
			if item:
				var player: Node = get_tree().get_first_node_in_group("player")
				if player:
					player.try_open_context_menu(get_global_mouse_position(), item, btn)
				else:
					print("❌ Player not found in group 'player'")

# ----------------------------
# TOGGLE INVENTORY VISIBILITY
# ----------------------------
func toggle() -> void:
	visible = not visible
