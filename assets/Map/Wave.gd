extends Node2D

onready var waves = [$wave, $wave2, $wave3]
onready var splash_particles = [$splash, $splash2, $splash3]
onready var colors = ["1f2baa", "121c91", "090f4b"]

var starting_curve: Array
var target_curve: Array
var og: Array
var curve

var amp_y = 200

var timer_stage: float

func init(curve):
	$Area2D/CollisionPolygon2D.disabled = true
	
	self.curve = curve
	$WavePath.curve = self.curve
	
	starting_curve.clear()
	target_curve.clear()
	og.clear()
	
	for i in range($WavePath.curve.get_point_count()):
		starting_curve.push_back($WavePath.curve.get_point_position(i))
		target_curve.push_back($WavePath.curve.get_point_position(i))
		og.push_back($WavePath.curve.get_point_position(i))
	
	# Cheap
	$WavePath.curve.bake_interval = 15
	var baked = $WavePath.curve.get_baked_points()
	baked.push_back(Vector2(baked[-1].x, 3000))
	baked.push_back(Vector2(baked[0].x, 3000))
	
	# VFX
	for i in 3:
		waves[i].set_polygon(baked)
		waves[i].material.set_shader_param("width", Globals.buffer_size.x)
		waves[i].color = Color(colors[i])
		splash_particles[i].modulate = Color(colors[i])
		splash_particles[i].emitting = true
		set_splash_amount(i, WorldEnv.get_weather())
	
	# Costly
	$WavePath.curve.bake_interval = 200
	baked = $WavePath.curve.get_baked_points()
	baked.push_back(Vector2(Globals.buffer_size.x, 3000))
	baked.push_back(Vector2(0, 3000))
	baked.push_back(Vector2(0, baked[0].y))
	$Area2D/CollisionPolygon2D.set_polygon(baked)
	$Area2D/CollisionPolygon2D.disabled = false

func _ready():
	WorldEnv.connect("update_weather", self, "_on_Game_update_weather")

func get_baked_points():
	return self.curve.get_baked_points()

func get_last_point():
	return self.get_point(-1)

func get_point(index):
	return $WavePath.curve.get_baked_points()[index] + self.global_position

func get_len_points():
	return len($WavePath.curve.get_baked_points())

func get_len():
	return $WavePath.curve.get_baked_length()

func interpolate_baked(x_in_buffer):
	return self.curve.interpolate_baked(x_in_buffer) + self.global_position

func set_splash_pos(i):
	var pos = self.get_point(randi() % self.get_len_points()) - self.global_position
	splash_particles[i].position = pos + waves[i].offset
	
	var visibility_size = 1000000
	splash_particles[i].visibility_rect = Rect2(Vector2(pos.x - visibility_size/2, pos.y - visibility_size/2), Vector2(visibility_size, visibility_size))

func set_splash_amount(i, amount):
	splash_particles[i].lifetime = 2 + (1 - amount) * 10
	splash_particles[i].emitting = amount > 0.0

func _process(delta):
	for i in 3:
		set_splash_pos(i)
	
	for i in range(self.curve.get_point_count()):
		self.curve.set_point_position(
			i,
			starting_curve[i]*(1.0 - timer_stage) + target_curve[i]*timer_stage
		)
	
	# Cheap
	$WavePath.curve.bake_interval = 10
	var baked = $WavePath.curve.get_baked_points()
	baked.push_back(Vector2(Globals.buffer_size.x, 3000))
	baked.push_back(Vector2(0, 3000))
	baked.push_back(Vector2(0, baked[0].y))

	# VFX
	for i in 3:
		waves[i].set_polygon(baked)
		waves[i].material.set_shader_param("width", Globals.buffer_size.x)
		waves[i].color = Color(colors[i])
		splash_particles[i].modulate = Color(colors[i])
		splash_particles[i].emitting = true
		set_splash_amount(i, WorldEnv.get_weather())

	# Costly
	$WavePath.curve.bake_interval = 150
	baked = $WavePath.curve.get_baked_points()
	baked.push_back(Vector2(Globals.buffer_size.x, 3000))
	baked.push_back(Vector2(0, 3000))
	baked.push_back(Vector2(0, baked[0].y))
	$Area2D/CollisionPolygon2D.set_polygon(baked)
	$Area2D/CollisionPolygon2D.disabled = false

func update_target_curve_fst():
	starting_curve = target_curve.duplicate()
	
	# First point can remain fixed (offscreen)
	for i in range(1, curve.get_point_count()):
		var prev_y = og[i].y
		var curr = target_curve[i]
		var shift_y = randi()%(2*amp_y)-amp_y
		if (prev_y + shift_y < 50 || prev_y + shift_y > 2000):
			shift_y = -shift_y
		target_curve[i] = Vector2(curr.x, prev_y + shift_y)

func update_target_curve_snd(p0, p1, p00, p11):
	starting_curve = target_curve.duplicate()
	
	target_curve[0] = p0
	target_curve[1] = p1
	
	starting_curve[0] = p00
	starting_curve[1] = p11

	for i in range(2, curve.get_point_count()):
		var prev_y = og[i].y
		var curr = target_curve[i]
		var shift_y = randi()%(2*amp_y)-amp_y
		if (prev_y + shift_y < 50 || prev_y + shift_y > 2000):
			shift_y = -shift_y
		target_curve[i] = Vector2(curr.x, prev_y + shift_y)

func _on_Area2D_body_shape_entered(body_id, body, body_shape, local_shape):
	if body.has_method("_on_hit_water"):
		body._on_hit_water()

func _on_Game_update_weather(value):
	for i in 3:
		set_splash_amount(i, value)
