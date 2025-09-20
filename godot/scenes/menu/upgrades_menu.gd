extends Control

var flash_button: Node
var sanity_button: Node
var currency_label:Node
var flash_upgrade_price = 20
var sanity_upgrade_price = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	flash_button = $TextureRect/MarginContainer/VBoxContainer/HBoxContainer/Upgrades/FlashlightUpgrade
	sanity_button = $TextureRect/MarginContainer/VBoxContainer/HBoxContainer/Upgrades/SanityUpgrade
	currency_label = $TextureRect/MarginContainer/VBoxContainer/CurrencyLabel

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	flash_button.text = "Flashlight: " + str(flash_upgrade_price)
	sanity_button.text = "Sanity: " + str(sanity_upgrade_price)
	currency_label.text = "Memory Shards: " + str(GameManager.currency)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")


func _on_flashlight_upgrade_pressed() -> void:
	if GameManager.currency >= flash_upgrade_price:
		UpgradesManager.upgrades.Flashlight += 30
		GameManager.currency -= flash_upgrade_price
		flash_upgrade_price += 20
	return

func _on_sanity_upgrade_pressed() -> void:
	if GameManager.currency >= sanity_upgrade_price:
		UpgradesManager.upgrades.Sanity += 20
		GameManager.currency -= sanity_upgrade_price
		sanity_upgrade_price += 20
