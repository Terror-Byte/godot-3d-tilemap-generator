class_name TileDefinition
extends Resource

@export var tile_asset: String
@export var tile_weight: float
@export var tile_asset_y_rotation: float
@export_group("Sockets", "socket_")
@export var socket_north: bool
@export var socket_east: bool
@export var socket_south: bool
@export var socket_west: bool
#var possible_neighbours: Dictionary[Globals.Direction, TileDefinition]


func _init(tile_asset_in: String = "", tile_weight_in: float = 0, socket_north_in: bool = false, socket_east_in: bool = false, socket_south_in: bool = false, socket_west_in: bool = false, tile_asset_y_rotation_in: float = 0) -> void:
	tile_asset = tile_asset_in
	tile_weight = tile_weight_in
	socket_north = socket_north_in
	socket_east = socket_east_in
	socket_south = socket_south_in
	socket_west = socket_west_in
	tile_asset_y_rotation = tile_asset_y_rotation_in


func get_direction_value(direction: Globals.Direction) -> bool:
	match direction:
		Globals.Direction.NORTH:
			return socket_north
		Globals.Direction.EAST:
			return socket_east
		Globals.Direction.SOUTH:
			return socket_south
		Globals.Direction.WEST:
			return socket_west
	# Shouldn't reach this case, but if so, return false anyways
	return false


func get_opposite_direction_value(direction: Globals.Direction) -> bool:
	match direction:
		Globals.Direction.NORTH:
			return socket_south
		Globals.Direction.EAST:
			return socket_west
		Globals.Direction.SOUTH:
			return socket_north
		Globals.Direction.WEST:
			return socket_east
	# Shouldn't reach this case, but if so, return false anyway
	return false
