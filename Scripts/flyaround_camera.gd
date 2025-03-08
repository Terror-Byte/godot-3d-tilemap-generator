class_name FlyaroundCamera
extends Camera3D

@export var _move_speed: float = 20
@export var _shifted_move_speed: float = 50
@export var _mouse_sensitivity: float = 0.3

var _pre_capture_mouse_position: Vector2 = Vector2()
var _look_position: Vector2 = Vector2()
var _total_pitch: float = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Globals.CurrentInputMode == Globals.InputMode.UI:
		return

	_camera_rotation()
	_camera_movement(delta)


func _input(event: InputEvent) -> void:
	if Globals.CurrentInputMode == Globals.InputMode.UI:
		return

	if event.is_action_pressed("right_click"):
		_pre_capture_mouse_position = get_viewport().get_mouse_position()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event.is_action_released("right_click"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Input.warp_mouse(_pre_capture_mouse_position)
		_pre_capture_mouse_position = Vector2(0, 0)

	if event is InputEventMouseMotion:
		_look_position = event.relative


func _get_relative_input() -> Vector3:
	var forward: float = Input.get_axis("move_forward", "move_back")
	var horizontal: float = Input.get_axis("move_left","move_right")
	return Vector3(horizontal, 0.0, forward)


func _get_global_input() -> Vector3:
	var vertical: float = Input.get_axis("move_down", "move_up")
	return Vector3(0.0, vertical, 0.0)


func _camera_movement(delta: float) -> void:
	var local_move_speed: float = 0
	if Input.is_action_pressed("shift"):
		local_move_speed = _shifted_move_speed
	else:
		local_move_speed = _move_speed
	translate(_get_relative_input() * local_move_speed * delta)
	global_translate(_get_global_input() * _move_speed * delta)


func _camera_rotation() -> void:
	# Rotation code taken from: https://github.com/richardhyy/simple-free-look-_camera-4/blob/master/_camera.gd
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_look_position *= _mouse_sensitivity
		var yaw: float = _look_position.x
		var pitch: float = _look_position.y
		_look_position = Vector2(0, 0)

	# Prevents looking up/down too far
		pitch = clamp(pitch, -90 - _total_pitch, 90 - _total_pitch)
		_total_pitch += pitch

		rotate_y(deg_to_rad(-yaw))
		rotate_object_local(Vector3(1, 0, 0), deg_to_rad(-pitch))
