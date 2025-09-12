extends Control

# --- NODES ---
@onready var soundtrack: AudioStreamPlayer = $MainSoundtrack
@onready var music_slider: HSlider = $SettingPanel/MusicSlider
@onready var mute_button: Button = $SettingPanel/MuteMusic  # Nom corrigé

# ----------------------------
# READY
# ----------------------------
func _ready() -> void:
	# Charger les paramètres sauvegardés
	_load_settings()

	# Connecter les signaux des boutons et sliders
	music_slider.value_changed.connect(_on_music_slider_changed)
	mute_button.toggled.connect(_on_mute_button_toggled)

# ----------------------------
# MENU BUTTONS
# ----------------------------
func _on_play_button_pressed() -> void:
	# Lancer le jeu / changer de scène
	get_tree().change_scene_to_file("res://scenes/WorldRoot.tscn")

func _on_setting_button_pressed() -> void:
	# Afficher le panneau des paramètres
	$SettingPanel.visible = true

func _on_quit_button_pressed() -> void:
	# Quitter le jeu
	get_tree().quit()

func _on_button_pressed() -> void:
	# Cacher le panneau des paramètres
	$SettingPanel.visible = false

# ----------------------------
# MUSIC HANDLING
# ----------------------------
func _on_music_slider_changed(value: float) -> void:
	# Convertir la valeur du slider (0-100) en volume DB
	var linear_value = value / 100.0
	soundtrack.volume_db = linear_to_db(linear_value)
	_save_settings()

func _on_mute_button_toggled(pressed: bool) -> void:
	# Mettre en pause ou reprendre la musique
	soundtrack.stream_paused = pressed
	_save_settings()

# ----------------------------
# SAVE SETTINGS
# ----------------------------
func _save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "volume", music_slider.value)
	config.set_value("audio", "muted", mute_button.button_pressed)
	config.save("user://settings.cfg")

# ----------------------------
# LOAD SETTINGS
# ----------------------------
func _load_settings() -> void:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		var volume: float = config.get_value("audio", "volume", 100.0)
		var muted: bool = config.get_value("audio", "muted", false)

		music_slider.value = volume
		soundtrack.volume_db = linear_to_db(volume / 100.0)
		mute_button.button_pressed = muted
		soundtrack.stream_paused = muted
	else:
		# Valeurs par défaut
		music_slider.value = 100.0
		mute_button.button_pressed = false
		soundtrack.stream_paused = false
