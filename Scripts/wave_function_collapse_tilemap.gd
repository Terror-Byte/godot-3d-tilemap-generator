class_name WaveFunctionCollapseTilemap
extends Node3D

signal tilemap_generation_complete

@export var tile_definition_collection: TileDefinitionCollection
@export var tilemap_width: int = 25
@export var tilemap_height: int = 25

var tilemap: Array[Tile]

var _initial_tile_definition_keys: Array[String]
var _initial_tile_definition_weights: PackedFloat32Array


func initialise_tile_definitions() -> void:
	for key: String in tile_definition_collection.tile_definitions.keys():
		_initial_tile_definition_keys.append(key)

	for key in _initial_tile_definition_keys:
		_initial_tile_definition_weights.append(tile_definition_collection.tile_definitions[key].tile_weight)


func initialise_tilemap() -> void:
	tilemap.clear()
	for index: int in tilemap_width * tilemap_height:
		var tile_pos: Vector2i = get_tilemap_coords_from_index(index)
		var new_tile: Tile = Tile.new(tile_pos, _initial_tile_definition_keys, _initial_tile_definition_weights)
		tilemap.append(new_tile)

	# Connect neighbour cells
	for index in range(tilemap.size()):
		var current_tile := tilemap[index]
		var tile_coords := current_tile.position
		if (tile_coords.y < tilemap_height - 1):
			current_tile.neighbours[Globals.Direction.NORTH] = get_tile(tile_coords.x, tile_coords.y + 1)
		if (tile_coords.x < tilemap_width - 1):
			current_tile.neighbours[Globals.Direction.EAST] = get_tile(tile_coords.x + 1, tile_coords.y)
		if (tile_coords.y > 0):
			current_tile.neighbours[Globals.Direction.SOUTH] = get_tile(tile_coords.x, tile_coords.y - 1)
		if (tile_coords.x > 0):
			current_tile.neighbours[Globals.Direction.WEST] = get_tile(tile_coords.x - 1, tile_coords.y)


func reset_tilemap() -> void:
	for index: int in tilemap_width * tilemap_height:
		var tile := tilemap[index]
		tile.reset_tile(_initial_tile_definition_keys, _initial_tile_definition_weights)


# Returns true if tilemap generation successful, false if unsuccessful
func generate_tilemap() -> bool:
	print("Tilemap generation initiated")
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = Time.get_ticks_msec()
	while !_are_all_tiles_collapsed():
		# Enumerate tiles with lowest entropy
		var lowest_entropy_tiles := _get_lowest_entropy_tiles()
		if lowest_entropy_tiles.size() == 0:
			break

		# Randomly pick tile from list and collapse it
		var chosen_tile_index := lowest_entropy_tiles[rng.randi_range(0, lowest_entropy_tiles.size() - 1)]
		var chosen_tile := tilemap[chosen_tile_index]
		chosen_tile.collapse()

		# Constrain all affected tiles
		var tiles_to_constrain: Array[Tile]
		tiles_to_constrain.push_front(chosen_tile)
		while tiles_to_constrain.size() > 0:
			var current_tile: Tile = tiles_to_constrain.pop_front()
			for direction: Globals.Direction in Globals.Direction.values():
				if !current_tile.neighbours.has(direction):
					continue

				var current_neighbour: Tile = current_tile.neighbours[direction]
				var possible_tiles: Array[String]
				if current_tile.get_entropy() > 0:
					possible_tiles = current_tile.possible_tiles.duplicate()
				else:
					possible_tiles.append(current_tile.chosen_tile)

				if current_neighbour.constrain(direction, possible_tiles, tile_definition_collection.tile_definitions):
					tiles_to_constrain.push_front(current_neighbour)
	
	print("Tilemap generation complete")
	tilemap_generation_complete.emit.call_deferred()
	return true


func get_tile(x: int, y: int) -> Tile:
  # TODO: Do we want to just throw an error here and panic, or return -1 and have the function caller deal with the error?
	var index: int = x + tilemap_width * y
	if index >= 0 && index < tilemap.size():
		return tilemap[index]
	else:
		return null


func get_tilemap_coords_from_index(index: int) -> Vector2i:
  # TODO: Do we want to throw an error here too?
	if index < 0 || index >= tilemap_width * tilemap_height:
		return Vector2(0, 0)

	var x: int = index % tilemap_width
	var y: int = index / tilemap_width
	return Vector2i(x, y)


func _get_lowest_entropy_tiles() -> Array[int]:
	var results: Array[int]
	var lowest_entropy: int = Globals.MAX_INT

	for i in range(0, tilemap.size()):
		var entropy := tilemap[i].get_entropy()
		if entropy < lowest_entropy && entropy > 0:
			lowest_entropy = tilemap[i].get_entropy()
	
	for i in range(0, tilemap.size()):
		if tilemap[i].get_entropy() == lowest_entropy:
			results.append(i)

	return results


func _are_all_tiles_collapsed() -> bool:
	for tile in tilemap:
		if tile.collapsed == false:
			return false
	return true


func _print_tile_definitions() -> void:
	for key: String in tile_definition_collection.tile_definitions:
		var tile_def: TileDefinition = tile_definition_collection.tile_definitions[key]
		print("Key: " + key)
		print("tile_asset: " + tile_def.tile_asset)
		print("sockets:")
		print("	- north: " + str(tile_def.socket_north))
		print("	- east: " + str(tile_def.socket_east))
		print("	- south: " + str(tile_def.socket_south))
		print("	- west: " + str(tile_def.socket_west))
		print("tile_asset_y_rotation: " + str(tile_def.tile_asset_y_rotation))
		print("")
