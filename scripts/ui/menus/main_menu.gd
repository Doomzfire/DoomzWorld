extends Control

# ============================
# --- NODES REFERENCES ---
# ============================
@onready var music_manager: Node = $MusicManager
@onready var settings_panel: Panel = $SettingPanel
@onready var background: TextureRect = $Background
@onready var hover_sound: AudioStreamPlayer = $HoverButtonSound
@onready var click_sound: AudioStreamPlayer = $ClickButtonSound

# Menu buttons
@onready var play_button: Button = $MenuButton/PlayButton
@onready var quit_button: Button = $MenuButton/QuitButton
@onready var setting_button: Button = $MenuButton/SettingButton
@onready var back_button: Button = $SettingPanel/BackButton

# ============================
# --- BACKGROUNDS ---
# ============================
@export var backgrounds: Array[Texture2D] = []
@export var background_change_interval: float = 25.0
var current_bg_index: int = -1
var remaining_bg_indices: Array[int] = []
var bg_timer: Timer

# ============================
# --- READY ---
# ============================
func _ready() -> void:
	_setup_ui_signals()
	_init_background_timer()
	_init_bg_shuffle()
	_set_next_bg()

	# Connecter le signal du SettingsPanel pour mettre à jour la musique
	settings_panel.connect("settings_changed", Callable(self, "_on_settings_changed"))

# ============================
# --- UI BUTTON SIGNALS ---
# ============================
func _setup_ui_signals() -> void:
	# Menu buttons
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	setting_button.pressed.connect(_on_setting_pressed)
	back_button.pressed.connect(_on_back_pressed)

	for button in [$MenuButton/PlayButton, $MenuButton/QuitButton, $MenuButton/SettingButton, $SettingPanel/BackButton]:
		button.connect("mouse_entered", Callable(self, "_on_button_hovered"))

# Hover / Click sounds
func _on_button_hovered() -> void:
	if hover_sound.playing:
		hover_sound.stop()
	hover_sound.play()

func _play_click_sound() -> void:
	if click_sound.playing:
		click_sound.stop()
	click_sound.play()

# ============================
# --- MENU BUTTON ACTIONS ---
# ============================
func _on_play_pressed() -> void:
	_play_click_sound()
	await _delay_action(5.0, Callable(self, "_change_to_world"))

func _change_to_world() -> void:
	get_tree().change_scene_to_file("res://scenes/WorldRoot.tscn")

func _on_quit_pressed() -> void:
	_play_click_sound()
	await _delay_action(5.0, Callable(self, "_quit_game"))

func _quit_game() -> void:
	get_tree().quit()

func _on_setting_pressed() -> void:
	settings_panel.visible = true
	_play_click_sound()

func _on_back_pressed() -> void:
	settings_panel.visible = false
	_play_click_sound()

func _delay_action(seconds: float, action: Callable) -> void:
	var timer = get_tree().create_timer(seconds)
	await timer.timeout
	action.call()

# ============================
# --- MUSIC SETTINGS HANDLER ---
# ============================
func _on_settings_changed(volume: float, muted: bool) -> void:
	music_manager.set_volume(volume)
	music_manager.set_muted(muted)

# ============================
# --- BACKGROUND SHUFFLE ---
# ============================
func _init_bg_shuffle() -> void:
	remaining_bg_indices.clear()
	for i in range(backgrounds.size()):
		remaining_bg_indices.append(i)
	remaining_bg_indices.shuffle()

func _set_next_bg() -> void:
	if remaining_bg_indices.size() == 0:
		_init_bg_shuffle()
	var next_index = remaining_bg_indices.pop_front()
	background.texture = backgrounds[next_index]
	current_bg_index = next_index

func _init_background_timer() -> void:
	bg_timer = Timer.new()
	bg_timer.wait_time = background_change_interval
	bg_timer.one_shot = false
	bg_timer.autostart = true
	add_child(bg_timer)
	bg_timer.timeout.connect(_on_bg_timer_timeout)

func _on_bg_timer_timeout() -> void:
	_set_next_bg()
