extends CharacterBody2D

# --- EXPORTS ---
@export var speed: float = 200.0

# --- NODES ---
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var idle_timer: Timer = $IdleTimer
@onready var camera: Camera2D = $Camera2D

# --- MOVEMENT STATE ---
var idle_playing: bool = false
var can_move: bool = true
var target_pos: Vector2 = Vector2.ZERO
var moving_to_target: bool = false
var idle_state: String = "none"  # "none", "forward", "backward"

# --- HUD / INVENTORY ---
var inventory_panel: Node = null
var item_context_menu: Node = null

# ----------------------------
# SETUP HUD
# ----------------------------
func set_hud(hud: Node) -> void:
	inventory_panel = hud.get_node("InventoryPanel")
	item_context_menu = hud.get_node("ItemContextMenu")

	if item_context_menu:
		# Connect menu signals to the player
		item_context_menu.connect("use_item", Callable(self, "_on_use_item"))
		item_context_menu.connect("drop_item", Callable(self, "_on_drop_item"))

# ----------------------------
# PHYSICS PROCESS
# ----------------------------
func _physics_process(_delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO

	# --- Automatic movement to target (right-click) ---
	if moving_to_target:
		direction = (target_pos - global_position).normalized()
		if global_position.distance_to(target_pos) < 5:
			moving_to_target = false
			direction = Vector2.ZERO

	# --- Keyboard movement (lock mode) ---
	if can_move and camera.follow_mode:
		if Input.is_action_pressed("move_right"):
			direction.x += 1
		if Input.is_action_pressed("move_left"):
			direction.x -= 1
		if Input.is_action_pressed("move_down"):
			direction.y += 1
		if Input.is_action_pressed("move_up"):
			direction.y -= 1

	# Apply movement
	velocity = direction.normalized() * speed
	move_and_slide()

	# --- Animation handling ---
	if direction == Vector2.ZERO:
		# Idle animation
		if not idle_playing:
			anim.play("idle")
			if idle_timer.is_stopped():
				idle_timer.start()
	else:
		# Walking animation
		anim.play("right_walk")
		idle_timer.stop()
		idle_playing = false
		idle_state = "none"

	# --- Toggle inventory panel ---
	if Input.is_action_just_pressed("inventory") and inventory_panel:
		inventory_panel.toggle()

# ----------------------------
# CLICK-TO-MOVE
# ----------------------------
func move_to_position(pos: Vector2) -> void:
	target_pos = pos
	moving_to_target = true

func stop_move() -> void:
	moving_to_target = false

# ----------------------------
# IDLE TIMER CALLBACK
# ----------------------------
func _on_idle_timer_timeout() -> void:
	idle_playing = true
	idle_state = "forward"
	anim.play("idle_1")

func _on_anim_finished() -> void:
	if idle_state == "forward" and idle_playing:
		idle_state = "backward"
		anim.play_backwards("idle_1")
	else:
		idle_state = "none"
		idle_playing = false

# ----------------------------
# CONTEXT MENU HANDLING
# ----------------------------
func try_open_context_menu(pos: Vector2, item: Resource, clicked_node: Node) -> void:
	if not camera.follow_mode and item_context_menu:
		item_context_menu.show_menu(pos, item, clicked_node)
	elif inventory_panel and inventory_panel.visible:
		var parent = clicked_node
		while parent:
			if parent == inventory_panel:
				item_context_menu.show_menu(pos, item, clicked_node)
				return
			parent = parent.get_parent()
	else:
		print("❌ Menu blocked: camera locked + inventory closed")

# ----------------------------
# ITEM ACTIONS
# ----------------------------
func _on_use_item(item: Item, target_node: Node) -> void:
	print("Use item:", item.name, "on", target_node)

func _on_drop_item(item: Item, _target_node: Node) -> void:
	print("Drop item:", item.name)
	if inventory_panel and inventory_panel.has_method("remove_item"):
		inventory_panel.remove_item(item)

# ----------------------------
# ADD ITEM TO INVENTORY
# ----------------------------
func add_item_to_inventory(item: Item) -> void:
	if inventory_panel and item and inventory_panel.has_method("add_item"):
		inventory_panel.add_item(item)
