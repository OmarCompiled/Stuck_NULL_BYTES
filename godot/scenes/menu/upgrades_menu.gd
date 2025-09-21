extends Control

var flash_button: Node
var sanity_button: Node
var currency_label:Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	flash_button = $TextureRect/MarginContainer/VBoxContainer/HBoxContainer/Upgrades/FlashlightUpgrade
	sanity_button = $TextureRect/MarginContainer/VBoxContainer/HBoxContainer/Upgrades/SanityUpgrade
	currency_label = $TextureRect/MarginContainer/VBoxContainer/CurrencyLabel

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	flash_button.text = "Flashlight: " + str(UpgradesManager.prices.Flashlight)
	sanity_button.text = "Sanity: " + str(UpgradesManager.prices.Sanity)
	currency_label.text = "Memory Shards: " + str(GameManager.currency)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")


func _on_flashlight_upgrade_pressed() -> void:
	if GameManager.currency >= UpgradesManager.prices.Flashlight:
		UpgradesManager.upgrades.Flashlight += 15
		GameManager.currency -= UpgradesManager.prices.Flashlight
		UpgradesManager.prices.Flashlight += 20
	return

func _on_sanity_upgrade_pressed() -> void:
	if GameManager.currency >= UpgradesManager.prices.Sanity:
		UpgradesManager.upgrades.Sanity += 20
		GameManager.currency -= UpgradesManager.prices.Sanity
		UpgradesManager.prices.Sanity += 20
