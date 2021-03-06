extends Node

const INTRO = "intro"
const LOOP = "loop"
const END = "end"

const CALM = "calmBeforeTheStorm"
const COLERE = "colereDeNeptune"
const VALSE = "laValseDesFlots"
const DYNAMIQUE = "JeuneEtDynamiquePirate"

const MUSIC_ATTENUATION_STOP = -20

onready var currentIntroMusic = null
onready var currentLoopMusic = $CalmBeforeTheStorm
onready var currentEndMusic = null
onready var nextIntroMusic = null
onready var nextLoopMusic = null
onready var nextEndMusic = null
onready var currentMusic = null

onready var currentMusicType = LOOP
onready var currentMusicName = CALM
onready var nextMusicName = null
onready var musicToAttenuate = null
onready var musicAttenuationStart = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$CalmBeforeTheStorm.stream.set_loop(true)
	$StartColereDeNeptune.stream.set_loop(false)
	$LoopColereDeNeptune.stream.set_loop(true)
	$EndColereDeNeptune.stream.set_loop(false)
	$StartLaValseDesFlots.stream.set_loop(false)
	$LoopLaValseDesFlots.stream.set_loop(true)
	$EndLaValseDesFlots.stream.set_loop(false)
	$JeuneEtDynamiquePirate.stream.set_loop(true)
	currentMusic = currentLoopMusic
	currentMusic.play()
	currentMusic.connect("finished", self, "_on_CurrentMusic_finished")
	
	
func _on_CurrentMusic_finished():
	match currentMusicType:
		INTRO:
			if (currentLoopMusic != null && currentLoopMusic.stream.has_loop()):
				changeMusic(currentLoopMusic)
				currentMusicType = LOOP
			elif (currentEndMusic != null):
				changeMusic(currentEndMusic)
				currentMusicType = END
			else:
				changeMusicToNext()
		LOOP:
			currentMusic.stream.set_loop(true)
			if (currentEndMusic != null):
				changeMusic(currentEndMusic)
				currentMusicType = END
			else:
				changeMusicToNext()
		END:
			changeMusicToNext()
	
func changeMusic(next):
	currentMusic.disconnect("finished", self, "_on_CurrentMusic_finished")
	currentMusic = next
	currentMusic.play()
	currentMusic.connect("finished", self, "_on_CurrentMusic_finished")

func changeMusicToNext():
	musicToAttenuate = null
	if (nextIntroMusic != null):
		if (nextMusicName == COLERE):
			$TweenColereGronde.interpolate_method(
			nextIntroMusic,
			"set_volume_db",
			MUSIC_ATTENUATION_STOP,
			nextIntroMusic.get_volume_db(),
			Globals.TRANSITION * 1.0,
			Tween.TRANS_LINEAR,
			Tween.EASE_OUT
			)
			nextIntroMusic.set_volume_db(MUSIC_ATTENUATION_STOP)
			$TweenColereGronde.start()
		changeMusic(nextIntroMusic)
		updateMusicToNext()
		currentMusicType = INTRO
	elif (nextLoopMusic):
		changeMusic(nextLoopMusic)
		updateMusicToNext()
		currentMusicType = LOOP
	elif (nextEndMusic):
		changeMusic(nextEndMusic)
		updateMusicToNext()
		currentMusicType = END
	else:
		nextIntroMusic = currentIntroMusic
		nextLoopMusic = currentLoopMusic
		nextEndMusic = currentEndMusic
		changeMusicToNext()

func updateMusicToNext():
	currentMusicName = nextMusicName
	currentIntroMusic = nextIntroMusic
	currentLoopMusic = nextLoopMusic
	currentEndMusic = nextEndMusic
	nextMusicName = null
	
func cutCurrentMusic():
	if (currentMusicName == CALM || currentMusicName == DYNAMIQUE || currentMusicName == VALSE):
		currentMusic.disconnect("finished", self, "_on_CurrentMusic_finished")
		musicToAttenuate = currentMusic
		musicAttenuationStart = currentMusic.get_volume_db()
		$TweenMusicChange.interpolate_method(
			musicToAttenuate,
			"set_volume_db",
			musicAttenuationStart,
			MUSIC_ATTENUATION_STOP,
			Globals.TRANSITION,
			Tween.TRANS_LINEAR,
			Tween.EASE_OUT
			)
		$TweenMusicChange.start()
	
func scheduleBeforeTheStorm():
	if currentMusicName != CALM:
		currentLoopMusic.stream.set_loop(false)
		nextIntroMusic = null
		nextLoopMusic = $CalmBeforeTheStorm
		nextEndMusic = null
		nextMusicName = CALM
	elif nextMusicName != null:
		currentLoopMusic.stream.set_loop(true)
		nextIntroMusic = null
		nextLoopMusic = null
		nextEndMusic = null
		nextMusicName = null

func scheduleColereDeNeptune():
	cutCurrentMusic()
	if currentMusicName != COLERE:
		currentLoopMusic.stream.set_loop(false)
		nextIntroMusic = $StartColereDeNeptune
		nextLoopMusic = $LoopColereDeNeptune
		nextEndMusic = $EndColereDeNeptune
		nextMusicName = COLERE
	elif nextMusicName != null:
		currentLoopMusic.stream.set_loop(true)
		nextIntroMusic = null
		nextLoopMusic = null
		nextEndMusic = null
		nextMusicName = null
	
func scheduleValseDesFlots():
	cutCurrentMusic()
	if currentMusicName != VALSE:
		currentLoopMusic.stream.set_loop(false)
		nextIntroMusic = $StartLaValseDesFlots
		nextLoopMusic = $LoopLaValseDesFlots
		nextEndMusic = $EndLaValseDesFlots
		nextMusicName = VALSE
	elif nextMusicName != null:
		currentLoopMusic.stream.set_loop(true)
		nextIntroMusic = null
		nextLoopMusic = null
		nextEndMusic = null
		nextMusicName = null
	
func scheduleJeuneEtDynamiquePirate():
	cutCurrentMusic()
	if currentMusicName != DYNAMIQUE:
		currentLoopMusic.stream.set_loop(false)
		nextIntroMusic = null
		nextLoopMusic = $JeuneEtDynamiquePirate
		nextEndMusic = null
		nextMusicName = DYNAMIQUE
	elif nextMusicName != null:
		currentLoopMusic.stream.set_loop(true)
		nextIntroMusic = null
		nextLoopMusic = null
		nextEndMusic = null
		nextMusicName = null
		
func menuEnter():
	currentMusic.stream.set_stream_paused(true)
	$CalmBeforeTheStorm.play()

func menuExit():
	$CalmBeforeTheStorm.stop()
	currentMusic.stream.set_stream_paused(false)
	
func _on_TweenMusicChange_tween_all_completed():
		currentMusic.stop()
		musicToAttenuate.set_volume_db(musicAttenuationStart)
		changeMusicToNext()

