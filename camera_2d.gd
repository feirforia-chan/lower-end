extends Camera2D

@onready var camera = $"."
@onready var stats = $CanvasLayer/StatsContainer
@onready var controls = $CanvasLayer/ControlsOutliner
@onready var buildingsbutton = $CanvasLayer/BuildingsButton
@onready var closeui = $CanvasLayer/CloseUI
@onready var citybutton = $"../Sprite2D/ToledoButton"
var disabled = false

@export var move_speed: float = 500.0
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0

var target_zoom: float = 1.0
var is_dragging: bool = false

func _ready() -> void:
	target_zoom = zoom.x

func _process(delta: float) -> void:
	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_axis("ui_left", "ui_right")
	input_dir.y = Input.get_axis("ui_up", "ui_down")
	
	global_position += input_dir.normalized() * (move_speed / zoom.x) * delta

	zoom.x = lerp(zoom.x, target_zoom, 10.0 * delta)
	zoom.y = zoom.x
	
# To see the UI and disable camera movement
func _on_toledo_button_pressed() -> void:
	stats.visible = true
	controls.visible = true
	buildingsbutton.visible = true
	closeui.visible = true
	citybutton.visible = false
	disabled = true
func _on_close_ui_pressed() -> void:
	stats.visible = true
	controls.visible = true
	buildingsbutton.visible = false
	closeui.visible = false
	citybutton.visible = true
	disabled = false

func _unhandled_input(event: InputEvent) -> void:
	if disabled == true:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				is_dragging = true
			else:
				is_dragging = false
				
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				target_zoom = clamp(target_zoom + zoom_speed, min_zoom, max_zoom)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				target_zoom = clamp(target_zoom - zoom_speed, min_zoom, max_zoom)

	if event is InputEventMouseMotion and is_dragging:
		global_position -= event.relative / zoom.x
		global_position.x = clamp(global_position.x, limit_left, limit_right)
		global_position.y = clamp(global_position.y, limit_top, limit_bottom)
