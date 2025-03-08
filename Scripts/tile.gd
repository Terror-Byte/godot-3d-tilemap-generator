class_name Tile
extends RefCounted

var possible_tiles: Array[String]
var possible_tile_weights: PackedFloat32Array
var collapsed: bool = false
var chosen_tile: String = ""
var neighbours: Dictionary[Globals.Direction, Tile]
var position: Vector2i


func _init(position_in: Vector2i, possible_tiles_in: Array[String], possible_tile_weights_in: PackedFloat32Array) -> void:
	position = position_in
	possible_tiles = possible_tiles_in.duplicate()
	possible_tile_weights = possible_tile_weights_in.duplicate()


func reset_tile(possible_tiles_in: Array[String], possible_tile_weights_in: PackedFloat32Array) -> void:
	possible_tiles = possible_tiles_in.duplicate()
	possible_tile_weights = possible_tile_weights_in.duplicate()
	collapsed = false
	chosen_tile = ""


func collapse() -> void:
	if collapsed == true || possible_tiles.size() == 0:
		return

	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = Time.get_ticks_msec()
	chosen_tile = possible_tiles[rng.rand_weighted(possible_tile_weights)]
	possible_tiles.clear()
	collapsed = true


func constrain(direction: Globals.Direction, possible_neighbour_tiles: Array[String], tile_definitions: Dictionary) -> bool:
	var constrained := false
	if get_entropy() == 0 && possible_neighbour_tiles.size() == 0:
		print("Constrain early return")
		return constrained

	for index in range(possible_tiles.size() - 1, -1, -1):
		var tile_def_key: String = possible_tiles[index]
		var tile_def: TileDefinition = tile_definitions[tile_def_key]
		var has_possible_neighbour := false
		
		for possible_neighbour_tile: String in possible_neighbour_tiles:
			if !tile_definitions.has(possible_neighbour_tile):
				continue
			var neighbour_tile_def: TileDefinition = tile_definitions[possible_neighbour_tile]
			has_possible_neighbour = tile_def.get_opposite_direction_value(direction) == neighbour_tile_def.get_direction_value(direction)

		if !has_possible_neighbour:
			possible_tiles.remove_at(index)
			possible_tile_weights.remove_at(index)
			constrained = true

	return constrained


func get_entropy() -> int:
	return possible_tiles.size()
