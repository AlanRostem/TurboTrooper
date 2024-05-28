extends Control

onready var __rush_energy_bar = $RushEnergyBar
onready var __scrap_info = $ScrapInfo
onready var __health_info = $HealthInfo

onready var __message = $GlobalMessage

var __player

func connect_to_player(player):
	player.stats.connect("rush_energy_changed", __rush_energy_bar, "set_rush_energy")
	player.stats.connect("scrap_changed", __scrap_info, "set_scrap_count")
	player.stats.connect("health_changed", __health_info, "set_health")
	player.connect("tree_exited", self, "__player_deleted")
	__player = player

func _process(delta):
	if __player == null: return
	
	var p = (__player as Player)
	var dpad_on = p.is_on_ground() and \
		p.is_moving_exactly_at_speed(PlayerSpeedValues.PLAYER_TOP_SPRINT_SPEED) and \
		p.stats.get_rush_energy() >= 2 and \
		p.state_machine.get_current_state() == "PlayerRunState"
	
	$DpadIndicatorSprite.frame = 1 if dpad_on else 0

func __player_deleted():
	__player = null

func set_global_message(text):
	__message.rect_size.x = 0
	__message.text = text
	__message.align = Label.ALIGN_CENTER
	__message.rect_position.y = 32
	if !__message.visible:
		__message.visible = true
	
func hide_global_message():
	__message.visible = false
