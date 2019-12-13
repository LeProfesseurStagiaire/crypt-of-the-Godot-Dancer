extends Node2D

onready var can_walk = false
onready var indic_move = preload("res://scene/enemi_indic_move.tscn")
var walk_count = 0
var rand_walk_count = 0
var is_walking = false
onready var main = get_tree().get_current_scene()
onready var speed = main.speed
onready var s = $sprite/s
onready var distance = 64
var dir = Vector2()
var shake_time = 0
var ray = "down"
var next_pos_possible = []
var pos_possible = ["left","right","up","down"]
var dead = false
var dir_selected = null

func _ready():
	randomize()
	main.connect("pulse",self,"move")
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

func move():
	print(can_walk)
	if can_walk:
		is_walking = true
		if dir && !get_node("rays/ray_"+str(dir_selected)).is_colliding() && !dead:
			can_walk = false
			var next_pos = Vector2(distance*dir.x,distance*dir.y)
			$position.interpolate_property(self,"position",position,position + next_pos,speed,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
			$s_scale.interpolate_property(s,"scale",s.scale * 1.1,s.scale,speed,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
			$s_color.interpolate_property(s,"modulate",s.modulate,Color(1, 0, 0),speed*3,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
			$position.start()
			$s_scale.start()
			$s_color.start()
			$anim.play("jump")
			walk_count =  0
			rand_walk_count = rand_range(0,4)
			z_index = ((position.y + next_pos.y)/64)-0.5
			if dir.x:
				$sprite.scale = Vector2(dir.x,1)
	else:
		if walk_count < rand_walk_count:
			walk_count +=1
		elif !dead:
			$anim.play("jump")
			can_walk = true
			next_pos_possible = []
			for p in pos_possible:
				if !get_node("rays/ray_"+str(p)).is_colliding():
					next_pos_possible.append(str(p))
			dir_selected = next_pos_possible[int(rand_range(0,next_pos_possible.size()))]
			if dir_selected == "up":
				dir = Vector2(0,-1)
			elif dir_selected == "down":
				dir = Vector2(0,1)
			elif dir_selected == "left":
				dir = Vector2(-1,0)
			elif dir_selected == "right":
				dir = Vector2(1,0)
			if global.game_difficulty[global.game_difficulty_selected] == "easy" or global.game_difficulty[global.game_difficulty_selected] == "medium":
				var ind = indic_move.instance()
				main.add_child(ind)
				ind.position = position + Vector2(distance*dir.x,distance*dir.y+64)
				ind.look_at(ind.position + Vector2(distance*dir.x*20,distance*dir.y*20+64))


func jump():
	is_walking = false
	$s_color.interpolate_property(s,"modulate",s.modulate,Color(1, 1, 1),speed*3,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	$s_color.start()

func die():
	can_walk = false
	$anim.play("die")
	$area/col.call_deferred("set_disabled",true)
	dead = true
	main.enemi_count -=1
