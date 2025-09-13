extends Node2D

# --- EXPORT ---
@export var item: Item  # Resource représentant l’item à ramasser

# --- NODES ---
@onready var sprite: Sprite2D = $Sprite2D

# ----------------------------
# READY
# ----------------------------
func _ready() -> void:
	# Affiche l’icône de l’item si disponible
	if item and item.icon:
		sprite.texture = item.icon

	# Connecte le signal de détection de collision
	$Area2D.body_entered.connect(_on_body_entered)

# ----------------------------
# HANDLE PLAYER COLLISION
# ----------------------------
func _on_body_entered(body: Node) -> void:
	# Vérifie si le corps appartient au groupe "player"
	if body.is_in_group("player"):
		# Tente d'ajouter l'item via la méthode centrale du Player
		if body.has_method("add_item_to_inventory"):
			print("📦 Player récupère l'item :", item.name)
			body.add_item_to_inventory(item)
			queue_free()  # Supprime l’objet après collecte
		else:
			print("❌ Player n'a pas la méthode add_item_to_inventory")
