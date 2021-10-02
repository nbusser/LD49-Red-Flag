extends Node2D

signal spawn_cannonball(projectile, shoot_origin, shoot_velocity)

onready var sight_loss_distance = 1.2*get_viewport_rect().size.x*Globals.MAX_UNZOOM

onready var primary_wave = $Wave0
onready var secondary_wave = $Wave1
var secondary_generated: bool

var next_buffer_offset
var x_in_buffer

func _ready():
	primary_wave.init($WaveGenerator.generate_buffer())
	secondary_wave.init($WaveGenerator.generate_buffer())
	secondary_wave.position.x = Globals.buffer_size.x
	secondary_generated = true
	x_in_buffer = 4000
	next_buffer_offset = 1


func player_move_checks():
	if (!secondary_generated):
		if (($Player.position.x - (next_buffer_offset-1)*Globals.buffer_size.x) > 2*sight_loss_distance):
			secondary_generated = true
			secondary_wave.init($WaveGenerator.generate_buffer())
			secondary_wave.position.x = next_buffer_offset*Globals.buffer_size.x
	elif (x_in_buffer > primary_wave.get_len()):
		next_buffer_offset += 1
		secondary_generated = false
		x_in_buffer = 0
		
		var tmp_wave = primary_wave
		primary_wave = secondary_wave
		secondary_wave = tmp_wave


func _process(delta):
	$Player.position = Vector2(primary_wave.interpolate_baked(x_in_buffer))
	x_in_buffer += $Player.speed*delta
	player_move_checks()
	
	var closest = primary_wave.curve.get_closest_point($Player.position + Vector2(35, 0) - primary_wave.global_position)
	var rot = closest.angle_to_point($Player.position - primary_wave.global_position)
	rot = clamp(rot, -1.0, 1.0)
	$Player/ship.rotation = lerp($Player/ship.rotation, rot, 10*delta)
	
	
	# TODO: if tempête, caméra bourrée en faisant
	# $Player.rotation = lerp($Player.rotation, rot, 5*delta)


func _on_Map_spawn_cannonball(projectile, shoot_origin, shoot_velocity):
	$Projectiles.add_child(projectile)
	projectile.global_transform.origin = shoot_origin
	projectile.linear_velocity = shoot_velocity
	yield(get_tree().create_timer(45), "timeout")
	projectile.queue_free()
