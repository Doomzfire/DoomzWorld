# res://items/consumables/HealthPotion.gd
extends Item
class_name HealthPotion

func _init():
	name = "Health Potion"
	description = "Restores 50 health points."
	item_type = "Consumable"
