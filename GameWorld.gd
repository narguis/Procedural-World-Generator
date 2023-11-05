extends Node2D
class_name GameWorld

signal started
signal finished

enum Cell {OBSTACLE, GROUND, OUTER}

export var inner_size := Vector2(10, 8)
export var perimeter_size := Vector2(1, 1)
export(float, 0, 1) var ground_probability := 0.1

# Public variables
var size := inner_size + 2 * perimeter_size 

# Private variables
onready var _tile_map : TileMap = $TileMap
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	setup()
	generate()
	

func setup() -> void:
	var map_size_px := size * _tile_map.cell_size
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, map_size_px)
	OS.set_window_size(2 * map_size_px)

func _pick_random_texture(cell_type : int) -> int:
	var interval := Vector2()
	if cell_type == Cell.OUTER:
		interval = Vector2(0, 9)
	elif cell_type == Cell.OBSTACLE:
		interval = Vector2(10, 14)
	elif cell_type == Cell.GROUND:
		interval = Vector2(15, 27)
	return _rng.randi_range(interval.x, interval.y)


func generate() -> void:
	emit_signal("started")
	_generate_perimeter()
	_generate_inner()
	emit_signal("finished")


func _generate_perimeter() -> void:
	for x in [0, size.x -1]:
		for y in range(0, size.y):
			_tile_map.set_cell(x, y, _pick_random_texture(Cell.OUTER))
	for x in range(1, size.x - 1):
		for y in [0, size.y - 1]:
			_tile_map.set_cell(x, y, _pick_random_texture(Cell.OUTER))

func _choose_inner(picked : int) -> int:
	return Cell.OBSTACLE if picked == 10 else Cell.GROUND

func _generate_inner() -> void:
	for x in range(1, size.x - 1):
		for y in range(1, size.y - 1):
			_tile_map.set_cell(x, y, _pick_random_texture(_choose_inner(_rng.randi_range(1, 10))))
	return

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		generate()
	
