extends Control

onready var __rush_energy_bar = $RushEnergyBar
onready var __scrap_info = $ScrapInfo
onready var __health_info = $HealthInfo

onready var __message = $GlobalMessage

func connect_to_player(player):
	player.stats.connect("rush_energy_changed", __rush_energy_bar, "set_rush_energy")
	player.stats.connect("scrap_changed", __scrap_info, "set_scrap_count")
	player.stats.connect("health_changed", __health_info, "set_health")

func set_global_message(text):
	__message.text = text
	if !__message.visible:
		__message.visible = true
	
func hide_global_message():
	__message.visible = false
