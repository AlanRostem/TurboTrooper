extends Control

onready var __scrap_info = $ScrapInfo
onready var __health_info = $HealthInfo

onready var __message = $GlobalMessage
onready var __score_count = $ScoreCount

func connect_to_player(player):
	# player.stats.connect("rush_energy_changed", __rush_energy_bar, "set_rush_energy")
	player.stats.connect("scrap_changed", __scrap_info, "set_scrap_count")
	player.stats.connect("health_changed", __health_info, "set_health")
	player.stats.connect("score_changed", self, "update_score_count")

func set_global_message(text):
	__message.rect_size.x = 0
	__message.text = text
	__message.align = Label.ALIGN_CENTER
	__message.rect_position.y = 32
	if !__message.visible:
		__message.visible = true
	
func hide_global_message():
	__message.visible = false
	
func update_score_count(score):
	__score_count.text = "score:" + str(score).pad_zeros(5)
