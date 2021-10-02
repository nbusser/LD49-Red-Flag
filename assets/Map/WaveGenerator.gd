extends Node2D

onready var previous_buffer_last_point = (2/3)*Globals.buffer_size
var next_y = 0


func _ready():
	pass


func get_control(previous, new):
	var angle = (new - previous).angle()
	var strength = 25 + randi()%50
	return Vector2(strength * cos(angle), strength * sin(angle))


func get_shift_x():
	return 100


func get_shift_y():
	return (randi()%200-100)


func add_point(curve):
	var points_count = curve.get_point_count()
	var previous = curve.get_point_position(points_count - 2)
	var current = curve.get_point_position(points_count - 1)
	
	# Insert new point
	var shift_y = get_shift_y()
	if (current.y + shift_y < 50 || current.y + shift_y > Globals.buffer_size.y - 50):
		shift_y = -shift_y
	var new = current + Vector2(get_shift_x(), shift_y)
	curve.add_point(new)
	
	# Adjust controls of the previous point
	var control = get_control(previous, new)
	curve.set_point_in(points_count - 1, -control)
	curve.set_point_out(points_count - 1, control)


func generate_buffer():
	var path = Path2D.new()
	var curve = path.curve
	
	curve.clear_points()
	var init_control = get_control(previous_buffer_last_point - Vector2(Globals.buffer_size.x, 0), Vector2(0, 0))
	curve.add_point(Vector2(0, next_y), -init_control, init_control)
	curve.add_point(Vector2(get_shift_x(), next_y))
	
	# 0.92: avoid generating the last point too close to the border
	while curve.get_point_position(curve.get_point_count() - 1).x < 0.92*Globals.buffer_size.x:
		add_point(curve)
	
	previous_buffer_last_point = curve.get_point_position(curve.get_point_count() - 1)
	next_y = previous_buffer_last_point.y + get_shift_y()
	
	var control = get_control(previous_buffer_last_point, Vector2(Globals.buffer_size.x, next_y))
	curve.set_point_in(curve.get_point_count() - 1, -control)
	curve.set_point_out(curve.get_point_count() - 1, control)
	
	curve.add_point(Vector2(Globals.buffer_size.x, next_y))
	
	return path
