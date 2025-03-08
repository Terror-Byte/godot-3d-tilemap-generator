extends Node3D

var _tilemap_generation_thread: Thread
var _tilemap_width_old: float
var _tilemap_height_old: float
var _tilemap_generation_in_progress: bool
var _camera_starting_pos: Vector3
var _camera_starting_rot: Vector3

@onready var _wave_function_collapse_tilemap: WaveFunctionCollapseTilemap = $WaveFunctionCollapseTilemap
@onready var _hud: HUD = $HUD
@onready var _camera: FlyaroundCamera = $FlyaroundCamera
@onready var _gridplane: MeshInstance3D = $GridPlane
@onready var _tile_assets: Dictionary[StringName, Resource] = {
	&"tile-grass": load("res://Scenes/tile_grass.tscn"),
	&"tile-dirt": load("res://Scenes/tile_dirt.tscn"),
	&"tile-straight": load("res://Scenes/tile_straight.tscn"),
	&"tile-end": load("res://Scenes/tile_end.tscn"),
	&"tile-corner-square": load("res://Scenes/tile_corner_square.tscn"),
	&"tile-split": load("res://Scenes/tile_split.tscn"),
	&"tile-crossing": load("res://Scenes/tile_crossing.tscn"),
	&"tile-tree": load("res://Scenes/tile_tree.tscn"),
	&"tile-rock": load("res://Scenes/tile_rock.tscn"),
	&"tile-hill": load("res://Scenes/tile_hill.tscn"),
	&"tile-crystal": load("res://Scenes/tile_crystal.tscn"),
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_camera_starting_pos = _camera.transform.origin
	_camera_starting_rot = _camera.rotation

	# Set up signals and UI
	_wave_function_collapse_tilemap.tilemap_generation_complete.connect(_on_tilemap_generation_complete)
	_hud.regenerate_button_pressed.connect(_regenerate_tilemap)
	_hud.ui_focus_entered.connect(_on_ui_focus_entered)
	_hud.ui_focus_exited.connect(_on_ui_focus_exited)

	_hud.set_tilemap_status_generating()

	var tilemap_width := Globals.DEFAULT_TILEMAP_WIDTH
	_wave_function_collapse_tilemap.tilemap_width = tilemap_width
	_tilemap_width_old = tilemap_width
	_hud.width_slider.min_value = Globals.MIN_TILEMAP_WIDTH
	_hud.width_slider.max_value = Globals.MAX_TILEMAP_WIDTH
	_hud.width_slider.value = tilemap_width
	_hud.width_slider_text_input.text = str(tilemap_width)
	_hud.old_width_text = str(tilemap_width)
	_hud.width_slider.value_changed.connect(_on_width_slider_value_changed)

	var tilemap_height := Globals.DEFAULT_TILEMAP_HEIGHT
	_wave_function_collapse_tilemap.tilemap_height = tilemap_height
	_tilemap_height_old = tilemap_height
	_hud.height_slider.min_value = Globals.MIN_TILEMAP_HEIGHT
	_hud.height_slider.max_value = Globals.MAX_TILEMAP_HEIGHT
	_hud.height_slider.value = tilemap_height
	_hud.height_slider_text_input.text = str(tilemap_height)
	_hud.old_height_text = str(tilemap_height)
	_hud.height_slider.value_changed.connect(_on_height_slider_value_changed)

	# Generate Tilemap
	_tilemap_generation_in_progress = true

	_wave_function_collapse_tilemap.initialise_tile_definitions()
	_wave_function_collapse_tilemap.initialise_tilemap()

	_tilemap_generation_thread = Thread.new()
	_tilemap_generation_thread.start(_wave_function_collapse_tilemap.generate_tilemap)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_gridplane.transform.origin.x = _camera.transform.origin.x
	_gridplane.transform.origin.z = _camera.transform.origin.z


func _input(event: InputEvent) -> void:
	if Globals.CurrentInputMode == Globals.InputMode.UI:
		return

	if event.is_action_pressed("regenerate_tilemap") && !_tilemap_generation_in_progress:
		_regenerate_tilemap()
		return
	
	if event.is_action_pressed("exit"):
		get_tree().quit()

	if event.is_action_pressed("teleport"):
		_camera.transform.origin = _camera_starting_pos
		_camera.rotation = _camera_starting_rot
		return


func _exit_tree() -> void:
	_tilemap_generation_thread.wait_to_finish()


func _draw_tilemap() -> void:
	print("Draw tilemap initiated")
	for index: int in range(_wave_function_collapse_tilemap.tilemap.size()):
		var tile: Tile = _wave_function_collapse_tilemap.tilemap[index]
		var tile_coords: Vector2 = _wave_function_collapse_tilemap.get_tilemap_coords_from_index(index)

		if tile.chosen_tile == "":
			continue

		var tile_definition: TileDefinition = _wave_function_collapse_tilemap.tile_definition_collection.tile_definitions[tile.chosen_tile]

		var new_tile: Node3D = _tile_assets[tile_definition.tile_asset].instantiate()
		var transform_offset := 0.5
		new_tile.transform.origin = Vector3(tile_coords.y + transform_offset, 0, tile_coords.x + transform_offset)
		new_tile.rotate_y(deg_to_rad(tile_definition.tile_asset_y_rotation))
		new_tile.name = "Tile" + str(index)
		_wave_function_collapse_tilemap.add_child(new_tile)
	print("Draw tilemap complete")


func _clear_tilemap() -> void:
	var tiles: Array[Node] = _wave_function_collapse_tilemap.get_children()
	for tile: Node in tiles:
		tile.queue_free()


func _regenerate_tilemap() -> void:
	_tilemap_generation_in_progress = true
	_hud.regenerate_button.disabled = true
	_hud.set_tilemap_status_generating()
	_clear_tilemap()

	if _wave_function_collapse_tilemap.tilemap_width != _tilemap_width_old || _wave_function_collapse_tilemap.tilemap_height != _tilemap_height_old:
		print("Width/Height changed")
		_wave_function_collapse_tilemap.initialise_tilemap()
		_tilemap_width_old = _wave_function_collapse_tilemap.tilemap_width
		_tilemap_height_old = _wave_function_collapse_tilemap.tilemap_height
	else:
		print("Width/Height not changed")
		_wave_function_collapse_tilemap.reset_tilemap()
		_tilemap_width_old = _wave_function_collapse_tilemap.tilemap_width
		_tilemap_height_old = _wave_function_collapse_tilemap.tilemap_height

	_tilemap_generation_thread.wait_to_finish()
	_tilemap_generation_thread = Thread.new()
	_tilemap_generation_thread.start(_wave_function_collapse_tilemap.generate_tilemap)


func _on_tilemap_generation_complete() -> void:
	_tilemap_generation_in_progress = false
	_draw_tilemap()
	_hud.regenerate_button.disabled = false
	_hud.set_tilemap_status_complete()


func _on_width_slider_value_changed(new_width: float) -> void:
	_tilemap_width_old = _wave_function_collapse_tilemap.tilemap_width
	_wave_function_collapse_tilemap.tilemap_width = int(new_width)


func _on_height_slider_value_changed(new_height: float) -> void:
	_tilemap_height_old = _wave_function_collapse_tilemap.tilemap_height
	_wave_function_collapse_tilemap.tilemap_height = int(new_height)


func _on_ui_focus_entered() -> void:
	Globals.CurrentInputMode = Globals.InputMode.UI


func _on_ui_focus_exited() -> void:
	Globals.CurrentInputMode = Globals.InputMode.GAME
