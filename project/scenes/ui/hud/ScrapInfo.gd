extends Control

onready var __count_label = $ScrapCountLabel

func set_scrap_count(count):
	__count_label.text = str(count).pad_zeros(3)
