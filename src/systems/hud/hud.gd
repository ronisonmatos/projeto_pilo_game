extends CanvasLayer

# ---------------------------------------------------------------------------
# Nós filhos
# ---------------------------------------------------------------------------
@onready var _health_bar:     TextureProgressBar = $VidaMoldura/VidaBarra
@onready var _faith_bar:      TextureProgressBar = $FeMoldura/FeBarra
@onready var _missao_btn:     TextureButton      = $MissaoBtn
@onready var _missao_caixa:   Control            = $MissaoCaixa
@onready var _config_btn:     TextureButton      = $ConfigBtn
@onready var _settings_panel: Control            = $SettingsPanel

# ---------------------------------------------------------------------------
# Ciclo de vida
# ---------------------------------------------------------------------------
func _ready() -> void:
	EventBus.player_health_changed.connect(on_health_changed)
	EventBus.player_faith_changed.connect(on_faith_changed)

# ---------------------------------------------------------------------------
# Interface pública — atualiza as barras de status do HUD
# ---------------------------------------------------------------------------
func on_health_changed(new_value: int, max_value: int) -> void:
	_health_bar.max_value = max_value
	_health_bar.value     = new_value

func on_faith_changed(new_value: int, max_value: int) -> void:
	_faith_bar.max_value = max_value
	_faith_bar.value     = new_value

# ---------------------------------------------------------------------------
# Painel de configurações
# ---------------------------------------------------------------------------
func _on_config_btn_pressed() -> void:
	_settings_panel.toggle()

## Chamado pelo sistema de login: carrega as configurações do perfil do usuário.
func apply_user_settings(settings: UserSettings) -> void:
	_settings_panel.load_user_settings(settings)

## Retorna as configurações atuais para salvar no perfil do usuário.
func get_settings_for_save() -> UserSettings:
	return _settings_panel.get_current_settings()

# ---------------------------------------------------------------------------
# Painel de missão
# ---------------------------------------------------------------------------
func _on_missao_btn_pressed() -> void:
	_missao_caixa.visible = not _missao_caixa.visible
