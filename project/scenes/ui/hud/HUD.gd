extends Control

#onready var __rush_energy_bar = $RushEnergyBar
onready var __scrap_info = $ScrapInfo
onready var __health_info = $HealthInfo

onready var __message = $GlobalMessage

onready var __selected_weapon_node = $BeamCannonDisplay

func connect_to_player(player):
	#player.stats.connect("rush_energy_changed", __rush_energy_bar, "set_rush_energy")
	player.stats.connect("scrap_changed", __scrap_info, "set_scrap_count")
	player.stats.connect("health_changed", __health_info, "set_health")
	player.stats.connect("turbo_slide_status_changed", self, "set_dpad_indicator_visible")
	player.stats.connect("weapon_changed", self, "set_weapon_display")
	player.stats.connect("weapon_ammo_changed", self, "set_weapon_ammo")
	
func set_weapon_ammo(ammo):
	if __selected_weapon_node == $BeamCannonDisplay:
		return
	__selected_weapon_node.get_node("AmmoLabel").text = str(ammo).pad_zeros(2)
	
func __select_weapon(node):
	__selected_weapon_node.get_node("AnimatedSprite").animation = "unselected"
	__selected_weapon_node = node
	__selected_weapon_node.get_node("AnimatedSprite").animation = "selected"

	
func set_weapon_display(weapon):
	if "Blaster" in weapon.name:
		__select_weapon($BeamCannonDisplay)
		return

	if "ScorchCannonWeapon" in weapon.name:
		__select_weapon($ScorchCannonDisplay)
		return
	if "BlastCannonWeapon" in weapon.name:
		__select_weapon($BlastCannonDisplay)
		return

func set_dpad_indicator_visible(flag: bool):
	$DpadIndicatorSprite.animation = "ready" if flag else "default"
	
func set_global_message(text):
	__message.rect_size.x = 0
	__message.text = text
	__message.align = Label.ALIGN_CENTER
	__message.rect_position.y = 32
	if !__message.visible:
		__message.visible = true
	
func hide_global_message():
	__message.visible = false
