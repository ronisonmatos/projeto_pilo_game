extends Control

# ---------------------------------------------------------------------------
# Constantes
# ---------------------------------------------------------------------------
const SAVE_PATH := "user://settings.tres"

# ---------------------------------------------------------------------------
# Estado interno
# ---------------------------------------------------------------------------
# Cada entrada: { "slider": HSlider, "label": Label }
var _sliders:  Dictionary = {}
var _applying: bool       = false   # bloqueia _save_to_disk durante carregamento

# ---------------------------------------------------------------------------
# Ciclo de vida
# ---------------------------------------------------------------------------
func _ready() -> void:
	_build_ui()
	_initialize_volumes()

# ---------------------------------------------------------------------------
# Interface pública
# ---------------------------------------------------------------------------
func toggle() -> void:
	visible = not visible
	if visible:
		_sync_sliders_from_audio()

## Aplica as configurações salvas no perfil do jogador.
func load_user_settings(settings: UserSettings) -> void:
	if not settings:
		return
	_applying = true
	_apply_to_audio(settings)
	_apply_to_sliders(settings.master_volume, settings.music_volume, settings.bgm_volume, settings.sfx_volume)
	_applying = false

## Retorna as configurações atuais para salvar no perfil do usuário logado.
func get_current_settings() -> UserSettings:
	var s := UserSettings.new()
	if _sliders.has("master"):
		s.master_volume = _sliders["master"]["slider"].value
	if _sliders.has("music"):
		s.music_volume  = _sliders["music"]["slider"].value
	if _sliders.has("bgm"):
		s.bgm_volume    = _sliders["bgm"]["slider"].value
	if _sliders.has("sfx"):
		s.sfx_volume    = _sliders["sfx"]["slider"].value
	return s

# ---------------------------------------------------------------------------
# Construção da UI em código
# (o nó já está centrado via anchors no main.tscn — sem tocar em posição aqui)
# ---------------------------------------------------------------------------
func _build_ui() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

	# Imagem de fundo
	var bg := TextureRect.new()
	bg.texture      = load("res://ui/bg_config.png")
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Container de conteúdo sobre o fundo
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top",    50)
	margin.add_theme_constant_override("margin_left",   50)
	margin.add_theme_constant_override("margin_right",  50)
	margin.add_theme_constant_override("margin_bottom", 40)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 22)
	margin.add_child(vbox)

	# Título
	var title := Label.new()
	title.text = "Configurações"
	title.add_theme_font_size_override("font_size", 20)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.107, 0.082, 0.012, 1.0))
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	_create_slider_row(vbox, "Volume Geral",    "master")
	_create_slider_row(vbox, "Música",          "music")
	_create_slider_row(vbox, "Música de Fundo", "bgm")
	_create_slider_row(vbox, "Efeitos Sonoros", "sfx")

func _create_slider_row(parent: Control, label_text: String, key: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	parent.add_child(row)

	var lbl := Label.new()
	lbl.text                  = label_text
	lbl.custom_minimum_size   = Vector2(150, 0)
	lbl.vertical_alignment    = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_color_override("font_color", Color(0.267, 0.225, 0.14, 1.0))
	row.add_child(lbl)

	var slider := HSlider.new()
	slider.min_value             = 0.0
	slider.max_value             = 1.0
	slider.step                  = 0.01
	slider.value                 = 1.0
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(func(v: float): _on_slider_changed(key, v))
	row.add_child(slider)

	var pct := Label.new()
	pct.custom_minimum_size  = Vector2(48, 0)
	pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pct.add_theme_color_override("font_color", Color(0.267, 0.225, 0.14, 1.0))
	pct.text = "100%"
	row.add_child(pct)

	_sliders[key] = { "slider": slider, "label": pct }

# ---------------------------------------------------------------------------
# Volume — AudioServer
# ---------------------------------------------------------------------------
func _initialize_volumes() -> void:
	var saved := _load_from_disk()
	if saved:
		_applying = true
		_apply_to_audio(saved)
		_apply_to_sliders(saved.master_volume, saved.music_volume, saved.bgm_volume, saved.sfx_volume)
		_applying = false
	else:
		_sync_sliders_from_audio()

func _sync_sliders_from_audio() -> void:
	_applying = true
	_apply_to_sliders(
		_db_to_slider(AudioServer.get_bus_volume_db(0)),
		_get_bus_slider("Music"),
		_get_bus_slider("Background_Sound_Map_1"),
		_get_bus_slider("SFX")
	)
	_applying = false

func _apply_to_sliders(master: float, music: float, bgm: float, sfx: float) -> void:
	_set_slider("master", master)
	_set_slider("music",  music)
	_set_slider("bgm",    bgm)
	_set_slider("sfx",    sfx)

func _set_slider(key: String, value: float) -> void:
	if not _sliders.has(key):
		return
	_sliders[key]["slider"].value = value
	_sliders[key]["label"].text   = "%d%%" % roundi(value * 100)

func _on_slider_changed(key: String, value: float) -> void:
	if _sliders.has(key):
		_sliders[key]["label"].text = "%d%%" % roundi(value * 100)
	_set_bus_volume(key, value)
	if not _applying:
		_save_to_disk()

func _set_bus_volume(key: String, value: float) -> void:
	var db := -80.0 if value <= 0.001 else linear_to_db(value)
	match key:
		"master":
			AudioServer.set_bus_volume_db(0, db)
		"music":
			var idx := AudioServer.get_bus_index("Music")
			if idx >= 0:
				AudioServer.set_bus_volume_db(idx, db)
		"bgm":
			var idx := AudioServer.get_bus_index("Background_Sound_Map_1")
			if idx >= 0:
				AudioServer.set_bus_volume_db(idx, db)
		"sfx":
			var idx := AudioServer.get_bus_index("SFX")
			if idx >= 0:
				AudioServer.set_bus_volume_db(idx, db)

func _apply_to_audio(settings: UserSettings) -> void:
	_set_bus_volume("master", settings.master_volume)
	_set_bus_volume("music",  settings.music_volume)
	_set_bus_volume("bgm",    settings.bgm_volume)
	_set_bus_volume("sfx",    settings.sfx_volume)

func _get_bus_slider(bus_name: String) -> float:
	var idx := AudioServer.get_bus_index(bus_name)
	return _db_to_slider(AudioServer.get_bus_volume_db(idx)) if idx >= 0 else 1.0

func _db_to_slider(db: float) -> float:
	return 0.0 if db <= -80.0 else clampf(db_to_linear(db), 0.0, 1.0)

# ---------------------------------------------------------------------------
# Persistência em disco
# ---------------------------------------------------------------------------
func _save_to_disk() -> void:
	var settings := UserSettings.new()
	settings.master_volume = _sliders["master"]["slider"].value
	settings.music_volume  = _sliders["music"]["slider"].value
	settings.bgm_volume    = _sliders["bgm"]["slider"].value
	settings.sfx_volume    = _sliders["sfx"]["slider"].value
	ResourceSaver.save(settings, SAVE_PATH)

func _load_from_disk() -> UserSettings:
	if not ResourceLoader.exists(SAVE_PATH):
		return null
	return ResourceLoader.load(SAVE_PATH) as UserSettings
