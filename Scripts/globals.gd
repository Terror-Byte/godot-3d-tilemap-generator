extends Node

enum Direction {
	NORTH,
	EAST,
	SOUTH,
	WEST,
}

enum InputMode {
	GAME,
	UI,
}

const MAX_INT: int = 9223372036854775807
const MIN_TILEMAP_WIDTH: int = 5
const MAX_TILEMAP_WIDTH: int = 50
const DEFAULT_TILEMAP_WIDTH: int = 25
const MIN_TILEMAP_HEIGHT: int = 5
const MAX_TILEMAP_HEIGHT: int = 50
const DEFAULT_TILEMAP_HEIGHT: int = 25

var CurrentInputMode: InputMode = InputMode.GAME
