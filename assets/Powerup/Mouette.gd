extends Node2D

onready var player = get_parent().get_node("Player")

var velocity = Vector2(0, 0)

var is_dead = false

enum DIRECTION {
	LEFT_TO_RIGHT = 1
	RIGHT_TO_LEFT = -1
}

var dir
var destination_x

const COEF_DIST = 0.5
var original_offset

func init(player, offset_player_y, direction=DIRECTION.LEFT_TO_RIGHT):
	self.player = player
	self.dir = direction
	self.original_offset = offset_player_y

	global_position = player.global_position - Vector2(
		Globals.buffer_size.x*COEF_DIST * direction,
		offset_player_y
	)
	
	match direction:
		DIRECTION.LEFT_TO_RIGHT:
			velocity.x = Globals.PLAYER_MAXIMUM_SPEED * 1.2
			$Birds/bird_right.show()
			$Birds/bird_left.hide()
			$Hitbox/hitbox_left.disabled = true
		DIRECTION.RIGHT_TO_LEFT:
			velocity.x = Globals.PLAYER_DEFAULT_SPEED
			$Birds/bird_right.hide()
			$Birds/bird_left.show()
			$Hitbox/hitbox_right.disabled = true

func _ready():
	$SoundFx/SpawnSound.play()

func _process(delta):
	var destination_x = player.global_position.x + (Globals.buffer_size.x*COEF_DIST * self.dir)
	if (
		(
			dir == DIRECTION.LEFT_TO_RIGHT
			and global_position.x > destination_x
		) or
		(
			dir == DIRECTION.RIGHT_TO_LEFT
			and global_position.x < destination_x
		)
	):
		queue_free()
	
	var max_speed_y = 500
	if global_position.y > player.global_position.y - original_offset:
		velocity.y +=  (max_speed_y/2)*delta
	else:
		velocity.y -= (max_speed_y/2)*delta
		
	velocity.y = clamp(velocity.y, -max_speed_y, max_speed_y)
		
	position.x += delta*velocity.x*dir
	position.y -= delta*velocity.y

func _on_Hitbox_body_entered(body):
	if is_dead:
		return
	
	is_dead = true
	player.recover_health()
	$SoundFx/DeathSound.play_sound()
	
	Utils.fade_node_out(self, 0.5)
	
	$Tween.interpolate_property(self, "rotation",
	self.rotation, deg2rad(dir * 90), 1,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	$Tween.interpolate_property(self, "position",
	self.position, Vector2(self.position.x + dir * 1500, self.position.y + 3000), 5,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	
	$Tween.start()
	
func _on_Tween_tween_completed(object, key):
	if object == $Birds and key == ":modulate":
		queue_free()
