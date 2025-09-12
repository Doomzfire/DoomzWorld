extends Node

# --- PRELOADS ---
@onready var hud_scene: PackedScene = preload("res://scenes/UI/HUD.tscn")

# --- NODES REFERENCES ---
var hud: Node = null
var current_map: Node = null
var player: Node = null

# ----------------------------
# READY
# ----------------------------
func _ready() -> void:
	# --- Instancier le HUD ---
	hud = hud_scene.instantiate()
	add_child(hud)

	# --- Récupérer le Player (enfant direct de WorldRoot) ---
	player = get_node_or_null("Player")
	if not player:
		push_error("Player node not found in WorldRoot!")
		return

	# --- Connecter le HUD au Player ---
	if hud and hud.has_method("set_player"):
		hud.set_player(player)

	# --- Charger la première map ---
	load_map("res://scenes/maps/Shelter.tscn")

# ----------------------------
# MAP HANDLING
# ----------------------------
func load_map(map_path: String) -> void:
	# Supprimer l'ancienne map si elle existe
	if current_map:
		current_map.queue_free()

	# Charger et instancier la nouvelle map
	var map_scene: PackedScene = load(map_path)
	current_map = map_scene.instantiate()
	add_child(current_map)

	# Positionner le Player sur le SpawnPoint si présent
	var spawn: Node2D = current_map.get_node_or_null("SpawnPoint")
	if spawn and player:
		player.global_position = spawn.global_position
