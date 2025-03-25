extends Area2D

signal collected

enum UpgradeType {charge_jump, double_jump, orb, flight}
@export var type: UpgradeType = UpgradeType.charge_jump

func _ready() -> void:
	Game.instance.after_load.connect(save_check)
	body_entered.connect(on_body_entered)

func save_check() -> void:
	if Game.collected_items.has(name):
		collected.emit()

func on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		var player := body as PlayerController
		match type:
			UpgradeType.charge_jump:
				player.can_charge_jump = true
			UpgradeType.double_jump:
				player.extra_jumps += 1
			UpgradeType.orb:
				Game.orbs_collected += 1
				print(Game.orbs_collected)
			UpgradeType.flight:
				player.can_infi_jump = true
		Game.collected_items.append(name)
		Game.save_to_file()
		collected.emit()
