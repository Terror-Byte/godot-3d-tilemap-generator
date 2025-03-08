class_name TileDefinitionCollection
extends Resource

@export var tile_definitions: Dictionary[StringName, Resource]

func _init(tile_definitions_in: Dictionary[StringName, Resource] = {}) -> void:
	tile_definitions = tile_definitions_in
