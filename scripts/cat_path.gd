class_name CatPath extends Node

var nodes: Array[CatPathNode]

func _ready() -> void:
	for node in get_children():
		if node is CatPathNode: nodes.append(node)
