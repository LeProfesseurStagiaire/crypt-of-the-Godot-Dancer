extends Node2D

onready var p = $player
var damier_pos = 0
var dam_c = Color(1, 0.84845, 0.253906, 0.494118)
var speed = 0.2

# Délai entre chaque temps en millisecondes = 60*1000 / bpm (donc : 60000 / 120) = 500 ms 
# on multiplie en suite par 0.001 pour passer en millisecondes
export(int) var music_bpm = 130
onready var bpm = (60000/music_bpm)*0.001
var time = 0
var global_time = 0
var bpm_count = 0
var wrong_count = 0
onready var enemi_count = $enemi.get_child_count()

signal pulse

func _ready():
	$damier/Sprite.rect_position = Vector2(-12800,-12800)
	$damier.show()
	$canv/vignette.show()
	pulse()
	$canv/fautes.text = "miss : "+str(wrong_count)
	$canv/time.text = "time : "+str(int(global_time))
	$canv/bpm.text = "pulsations : "+str(bpm_count)
	$canv/dif.text = str(global.game_difficulty[global.game_difficulty_selected])

func _process(delta):
	if enemi_count <=0:
		if global.game_difficulty_selected < 2:
			global.game_difficulty_selected += 1
		else:
			get_tree().change_scene_to(load("res://scene/win.tscn"))
			return
		get_tree().change_scene_to(load("res://scene/level_"+str(global.game_difficulty_selected +1)+".tscn"))
	time += 1*delta
	global_time +=1*delta
	if time >= bpm:
		time = 0
		bpm_count += 1
		if damier_pos == -64:
			damier_pos = 64
			dam_c = Color(0.312195, 1, 0.253906, 0.494118)
		else:
			damier_pos = -64
			dam_c = Color(1, 0.84845, 0.253906, 0.494118)
		pulse()
		$canv/time.text = "temps : "+str(int(global_time))

func pulse():
	$damier/Sprite.rect_position.x += damier_pos
	$damier/color_alpha.interpolate_property($damier/Sprite,"self_modulate",
	Color(dam_c.r,dam_c.g,dam_c.v,0.6),Color(dam_c.r,dam_c.g,dam_c.v,0.4),speed,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	$damier/color_alpha.start()
	$tween/cam_scale.interpolate_property($player/Camera2D,"zoom",Vector2(1.025,1.025),Vector2(1,1),speed,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	$tween/vignette_scale.interpolate_property($canv/vignette,"scale",Vector2(8.7,5.5),Vector2(10,6.5),speed,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	$tween/cam_scale.start()
	$tween/vignette_scale.start()
	emit_signal("pulse")
	$canv/bpm.text = "pulsations : "+str(bpm_count)

func can_walk():
	if time >= bpm/global.game_param.get(global.game_difficulty[global.game_difficulty_selected]).get("less_time") or time <= bpm*global.game_param.get(global.game_difficulty[global.game_difficulty_selected]).get("max_time"):
		return true
	$canv/fautes.text = "erreurs : "+str(wrong_count)