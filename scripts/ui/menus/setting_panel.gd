extends Panel

# ============================
# --- NODES REFERENCES ---
# ============================
@onready var music_slider: HSlider = $MusicSlider
@onready var mute_checkbox: CheckBox = $MuteMusic
@onready var save_button: Button = $SaveSettingButton
@onready var reset_button: Button = $ResetSettingButton

# ============================
# --- SIGNALS ---
# ============================
signal settings_changed(volume: float, muted: bool)

# ============================
# --- READY ---
# ============================
func _ready() -> void:
	# Bouton Save caché au départ
	save_button.visible = false

	# Connexions des signaux
	music_slider.value_changed.connect(_on_setting_changed)
	mute_checkbox.toggled.connect(_on_setting_changed)
	save_button.pressed.connect(_on_save_pressed)
	reset_button.pressed.connect(_on_reset_pressed)

	# Charger les valeurs sauvegardées
	_load_settings()

# ============================
# --- GESTION DES CHANGEMENTS ---
# ============================
func _on_setting_changed(value: float = 0) -> void:
	# Tout changement montre le bouton Save
	save_button.visible = true

	# Émettre le signal pour le MainMenu / MusicManager
	emit_signal("settings_changed", music_slider.value, mute_checkbox.pressed)

# ============================
# --- SAVE / RESET BUTTONS ---
# ============================
func _on_save_pressed() -> void:
	_save_settings()
	save_button.visible = false  # Masquer après sauvegarde

func _on_reset_pressed() -> void:
	# Remise à zéro
	music_slider.value = 100
	mute_checkbox.pressed = false
	save_button.visible = true  # montrer car valeurs changées
	emit_signal("settings_changed", music_slider.value, mute_checkbox.pressed)

# ============================
# --- SAVE / LOAD SETTINGS ---
# ============================
func _save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "volume", music_slider.value)
	config.set_value("audio", "muted", mute_checkbox.pressed)
	config.save("user://settings.cfg")

func _load_settings() -> void:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		var volume: float = config.get_value("audio", "volume", 100.0)
		var muted_raw = config.get_value("audio", "muted", false)
		var muted: bool = bool(muted_raw)  # conversion explicite
		music_slider.value = volume
		await get_tree().process_frame
		mute_checkbox.pressed = muted


func _on_back_setting_button_pressed() -> void:
	pass # Replace with function body.
