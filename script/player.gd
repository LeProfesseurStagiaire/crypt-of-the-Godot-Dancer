extends Node2D

onready var can_walk = true
onready var main = get_tree().get_current_scene()
onready var speed = main.speed
onready var s = $sprite/s
onready var distance = 64
var dir = Vector2()
var shake_time = 0
var ray = "down"

func _ready():
	s.texture = load("res://assets/texture/player_"+str(global.game_difficulty[global.game_difficulty_selected])+".png")
	var x = 1
	while (position.x>(64*x)):
		 x+=1
	var y = 1
	while (position.y>(64*y)):
		 y+=1
	position = Vector2(x*64 -32,y*64 -32)
	$s_shadow.position.y = s.texture.get_size().y/2
	$area.position = $s_shadow.position
	$area/col.shape.set_extents(Vector2(10,10))

func _process(delta):
	if shake_time > 0:
		$Camera2D.offset = Vector2(rand_range(2,10),rand_range(2,10))
		shake_time -= 1 * delta
	else:
		$Camera2D.offset = Vector2(0,0)
	if can_walk:
		if Input.is_action_pressed("ui_left"):
			dir = Vector2(-1,0)
			ray = "left"
		elif Input.is_action_pressed("ui_right"):
			dir = Vector2(1,0)
			ray = "right"
		elif Input.is_action_pressed("ui_up"):
			dir = Vector2(0,-1)
			ray = "up"
		elif Input.is_action_pressed("ui_down"):
			dir = Vector2(0,1)
			ray = "down"
		else : 
			dir = Vector2(0,0)
		if dir && !get_node("rays/ray_"+str(ray)).is_colliding():
			if main.can_walk() or global.game_difficulty[global.game_difficulty_selected] == "easy":
				can_walk = false
				var next_pos = Vector2(distance*dir.x,distance*dir.y)
				$position.interpolate_property(self,"position",position,position + next_pos,speed,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
				$s_scale.interpolate_property(s,"scale",s.scale * 1.1,s.scale,speed,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
				$s_color.interpolate_property(s,"modulate",s.modulate,Color(1, 1, 1),speed*3,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
				$position.start()
				$s_scale.start()
				$s_color.start()
				$anim.play("jump")
				$move.start(speed*1.2)
				if dir.x:
					$sprite.scale = Vector2(dir.x,1)
				z_index = ((position.y + next_pos.y)/64)-0.5
				if !main.can_walk() :
					stop()
			else:
				stop()

func stop():
	main.wrong_count+=1
	shake_time = 0.15
	can_walk = false
	$move.stop()
	$move.start(speed*4)
	$s_color.interpolate_property(s,"modulate",s.modulate,Color(1,0,0),speed,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	$s_color.start()

func _on_Timer_timeout():
	if can_walk == false:
		can_walk = true
		$s_color.interpolate_property(s,"modulate",s.modulate,Color(1,1,1),speed,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		$s_color.start()

func _on_area_area_entered(area):
	if can_walk or area.get_parent().is_walking:
		$move.stop()
		can_walk = false
		$anim.play("die")
		$area/col.call_deferred("set_disabled",true)
	else:
		area.get_parent().die()
		shake_time = 0.10

func die():
	get_tree().reload_current_scene()