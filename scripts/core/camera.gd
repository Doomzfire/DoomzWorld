extends Camera2D

var follow_mode: bool = true
var dragging := false
var last_mouse_pos: Vector2
@onready var player = null
var free_position: Vector2 = Vector2.ZERO

# --- Zoom ---
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.38
@export var max_zoom: float = 2.0

# --- Smooth follow ---
@export var follow_smooth: float = 75.0

# --- Limite distance en mode libre ---
@export var free_max_distance_x: float = 2350.0
@export var free_max_distance_y: float = 1200.0

# --- Décalage caméra ---
@export var camera_offset: Vector2 = Vector2(0, -150)

func _ready():
	make_current()
	player = get_parent()  # la caméra est enfant du Player
	free_position = global_position

func _process(_delta):
	# Toggle lock/libre avec Y
	if Input.is_action_just_pressed("toggle_camera"):
		follow_mode = not follow_mode
		if player:
			player.can_move = follow_mode
		last_mouse_pos = get_viewport().get_mouse_position()
		free_position = global_position
		print("Camera mode:", "LOCK" if follow_mode else "FREE")

	# Mode lock : suit le Player
	if follow_mode and player:
		var target_pos = player.global_position + camera_offset
		global_position = global_position.move_toward(target_pos, follow_smooth * _delta * 60)
		var direction_pressed := Input.is_action_pressed("move_up") \
			or Input.is_action_pressed("move_down") \
			or Input.is_action_pressed("move_left") \
			or Input.is_action_pressed("move_right")
		if direction_pressed:
			player.stop_move()

	# Mode libre : drag gauche
	if not follow_mode:
		var mouse_pos = get_viewport().get_mouse_position()
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if not dragging:
				dragging = true
				last_mouse_pos = mouse_pos
			else:
				var delta_mouse = mouse_pos - last_mouse_pos
				free_position -= delta_mouse
				last_mouse_pos = mouse_pos
		else:
			dragging = false

		# Limiter la distance depuis le Player
		if player:
			var free_offset = free_position - player.global_position
			free_offset.x = clamp(free_offset.x, -free_max_distance_x, free_max_distance_x)
			free_offset.y = clamp(free_offset.y, -free_max_distance_y, free_max_distance_y)
			free_position = player.global_position + free_offset

		global_position = free_position

func _unhandled_input(event: InputEvent) -> void:
	# 🔹 Ferme le menu contextuel si clic en dehors
	if event is InputEventMouseButton and event.pressed:
		if player and player.item_context_menu and player.item_context_menu.visible:
			var menu_rect = player.item_context_menu.get_global_rect()
			if not menu_rect.has_point(get_global_mouse_position()):
				player.item_context_menu.visible = false

	# Clic droit → déplacement en mode free
	if event is InputEventMouseButton and event.button_index == 2 and event.pressed:
		var click_pos = get_global_mouse_position()
		if player and not follow_mode:
			player.move_to_position(click_pos)

	# Zoom
	if Input.is_action_just_pressed("zoom_in"):
		zoom = Vector2(clamp(zoom.x - zoom_speed, min_zoom, max_zoom),
					   clamp(zoom.y - zoom_speed, min_zoom, max_zoom))
	elif Input.is_action_just_pressed("zoom_out"):
		zoom = Vector2(clamp(zoom.x + zoom_speed, min_zoom, max_zoom),
					   clamp(zoom.y + zoom_speed, min_zoom, max_zoom))
