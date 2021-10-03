extends Control

onready var player: Node2D = get_viewport().get_node("Node/Map/Player")

func _ready():
	player.connect("start_charging_cannon", self, "start")
	player.connect("stop_charging_cannon", self, "stop")

func start():
	$Tween.stop_all()
	$Tween.interpolate_property($CannonChargingBar, "value",
	$CannonChargingBar.value, $CannonChargingBar.max_value,
	Globals.MAX_CANNON_CHARGING_TIME,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func stop():
	$Tween.stop_all()
	$Tween.interpolate_property($CannonChargingBar, "value",
	$CannonChargingBar.value, 0,
	0.1,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()