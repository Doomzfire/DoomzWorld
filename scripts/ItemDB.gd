extends Node

var defs: Dictionary = {
    "branch": {"name": "Branche", "icon": "res://assets/branch.png", "stack": 99, "use_heal": 0},
    "flint": {"name": "Silex", "icon": "res://assets/flint.png", "stack": 99, "use_heal": 0},
    "bandage": {"name": "Bandage", "icon": "res://assets/bandage.png", "stack": 10, "use_heal": 25}
}

func get_def(id: String) -> Dictionary:
    if defs.has(id):
        return defs[id]
    return {"name": id, "icon": "", "stack": 99, "use_heal": 0}
