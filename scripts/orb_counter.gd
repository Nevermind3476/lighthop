extends Label

signal all_orbs_collected

func _on_screen_entered() -> void:
	text = str(Game.orbs_collected) + "/" + str(Game.total_orbs)
	if Game.orbs_collected >= Game.total_orbs:
		all_orbs_collected.emit()
