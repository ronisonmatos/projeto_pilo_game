extends CanvasLayer

# ---------------------------------------------------------------------------
# Nós filhos
# ---------------------------------------------------------------------------
@onready var _health_bar:   TextureProgressBar = $VidaMoldura/VidaBarra
@onready var _faith_bar:    TextureProgressBar = $FeMoldura/FeBarra
@onready var _missao_btn:   TextureButton      = $MissaoBtn
@onready var _missao_caixa: Control            = $MissaoCaixa

# ---------------------------------------------------------------------------
# Ciclo de vida
# ---------------------------------------------------------------------------
func _ready() -> void:
	_validate_nodes()

# ---------------------------------------------------------------------------
# Interface pública
# ---------------------------------------------------------------------------

## Conecte ao sinal health_changed do Player:
##   player.health_changed.connect(hud.on_health_changed)
func on_health_changed(new_value: int, max_value: int) -> void:
	_health_bar.max_value = max_value
	_health_bar.value     = new_value

## Conecte ao sinal faith_changed do Player:
##   player.faith_changed.connect(hud.on_faith_changed)
func on_faith_changed(new_value: int, max_value: int) -> void:
	_faith_bar.max_value = max_value
	_faith_bar.value     = new_value

# ---------------------------------------------------------------------------
# Missão
# ---------------------------------------------------------------------------
func _on_missao_btn_pressed() -> void:
	_missao_caixa.visible = not _missao_caixa.visible

# ---------------------------------------------------------------------------
# Internos
# ---------------------------------------------------------------------------
func _validate_nodes() -> void:
	if not _health_bar:
		push_error("[HUD] VidaBarra não encontrada em VidaMoldura/VidaBarra")
	if not _faith_bar:
		push_error("[HUD] FeBarra não encontrada em FeMoldura/FeBarra")
	if not _missao_btn:
		push_error("[HUD] MissaoBtn não encontrado")
	if not _missao_caixa:
		push_error("[HUD] MissaoCaixa não encontrado")
