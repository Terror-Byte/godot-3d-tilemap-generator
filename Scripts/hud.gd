class_name HUD
extends Control

signal regenerate_button_pressed
signal width_slider_value_changed(new_width: float)
signal height_slider_value_changed(new_height: float)
signal ui_focus_entered
signal ui_focus_exited

var old_width_text: String
var old_height_text: String

@onready var regenerate_button: Button = $PanelContainer/MarginContainer/VBoxContainer/RegenerateTilemapButton
@onready var width_slider: Slider = $PanelContainer/MarginContainer/VBoxContainer/WidthSlider
@onready var width_slider_text_input: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/WidthSliderLabels/WidthSliderTextInput
@onready var height_slider: Slider = $PanelContainer/MarginContainer/VBoxContainer/HeightSlider
@onready var height_slider_text_input: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/HeightSliderLabels/HeightSliderTextInput

@onready var _generating_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TilemapStatusContainer/GeneratingLabel
@onready var _complete_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TilemapStatusContainer/CompleteLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect signals
	regenerate_button.focus_entered.connect(_focus_entered.bind("Regenerate Button"))
	regenerate_button.focus_exited.connect(_focus_exited.bind("Regenerate button"))

	width_slider.drag_started.connect(_focus_entered.bind("Width Slider"))
	width_slider.drag_ended.connect(func(_value_changed: bool) -> void:
		_focus_exited("Width Slider")
	)

	width_slider_text_input.focus_entered.connect(_focus_entered.bind("Width Slider Text Input"))
	width_slider_text_input.focus_exited.connect(func() -> void:
		var textbox_width_value: int = int(width_slider_text_input.text)
		if textbox_width_value == 0:
			print("[width_slider_text_input.focus_exited] textbox_width_value value not an integer OR is 0")
			width_slider_text_input.text = old_width_text
		else:
			if textbox_width_value != int(width_slider.value):
				width_slider_text_input.text = old_width_text
		_focus_exited("Width Slider Text Input")
	)

	height_slider.drag_started.connect(_focus_entered.bind("Height Slider"))
	height_slider.drag_ended.connect(func(_value_changed: bool) -> void:
		_focus_exited("Height Slider")
	)

	height_slider_text_input.focus_entered.connect(_focus_entered.bind("Height Slider Text Input"))
	height_slider_text_input.focus_exited.connect(func() -> void:
		var textbox_height_value: int = int(height_slider_text_input.text)
		if textbox_height_value == 0:
			print("[height_slider_text_input.focus_exited] textbox_height_value value not an integer OR is 0")
			height_slider_text_input.text = old_height_text
		else:
			if textbox_height_value != int(height_slider.value):
				height_slider_text_input.text = old_height_text
		_focus_exited("Height Slider Text Input")
	)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if width_slider_text_input.has_focus() && !width_slider_text_input.get_global_rect().has_point(get_viewport().get_mouse_position()):
			width_slider_text_input.release_focus()

		if height_slider_text_input.has_focus() && !height_slider_text_input.get_global_rect().has_point(get_viewport().get_mouse_position()):
			height_slider_text_input.release_focus()
	
	if event.is_action_pressed("exit"):
		if width_slider_text_input.has_focus():
			width_slider_text_input.release_focus()

		if height_slider_text_input.has_focus():
			height_slider_text_input.release_focus()


func set_tilemap_status_generating() -> void:
	_generating_label.visible = true
	_complete_label.visible = false


func set_tilemap_status_complete() -> void:
	_generating_label.visible = false
	_complete_label.visible = true


func _on_regenerate_button_pressed() -> void:
	regenerate_button_pressed.emit()
	regenerate_button.release_focus()


func _on_width_slider_value_changed(value: float) -> void:
	width_slider_text_input.text = str(value)
	old_width_text = str(value)
	width_slider_value_changed.emit(value)
	width_slider.release_focus()


func _on_width_slider_text_input_text_submitted(new_text: String) -> void:
	var new_width: int = int(new_text)
	if new_width == 0:
		print("[_on_width_slider_text_input_text_submitted] new_text value not an integer OR is 0")
		width_slider_text_input.text = old_width_text
		return
	width_slider.value = new_width
	old_width_text = new_text
	width_slider_text_input.release_focus()


func _on_height_slider_value_changed(value: float) -> void:
	height_slider_text_input.text = str(value)
	old_height_text = str(value)
	height_slider_value_changed.emit(value)
	height_slider.release_focus()


func _on_height_slider_text_input_text_submitted(new_text: String) -> void:
	var new_height: int = int(new_text)
	if new_height == 0:
		print("[_on_height_slider_text_input_text_submitted] new_text value not an integer OR is 0")
		height_slider_text_input.text = old_height_text
		return
	height_slider.value = new_height
	old_height_text = new_text
	height_slider_text_input.release_focus()


func _focus_entered(ui_element_name: String) -> void:
	print("Focus entered on " + ui_element_name)
	ui_focus_entered.emit()


func _focus_exited(ui_element_name: String) -> void:
	print("Focus exited on " + ui_element_name)
	ui_focus_exited.emit()
