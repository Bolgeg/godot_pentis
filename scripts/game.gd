extends Node2D

signal lost

const NEXT_PIECE_GRID_SIZE:=Vector2i(7,7)
@onready var next_piece_block_map:=%NextPieceBlockMap

var grid_size:=Vector2i(24,20)
@onready var main_block_map:=%MainBlockMap

var score:=0
@onready var score_label:=%ScoreLabel

const PIECE_TYPES:=[
	[
		[1,1,1,1,1],
	],
	[
		[0,1,1],
		[1,1,0],
		[0,1,0],
	],
	[
		[1,1,0],
		[0,1,1],
		[0,1,0],
	],
	[
		[1,0,0,0],
		[1,1,1,1],
	],
	[
		[1,1,1,1],
		[1,0,0,0],
	],
	[
		[0,1,1,0],
		[1,1,1,0],
	],
	[
		[1,1,1,0],
		[0,1,1,0],
	],
	[
		[1,1,0,0],
		[0,1,1,1],
	],
	[
		[0,1,1,1],
		[1,1,0,0],
	],
	[
		[1,1,1],
		[0,1,0],
		[0,1,0],
	],
	[
		[1,0,1],
		[1,1,1],
		[0,0,0],
	],
	[
		[0,0,1],
		[0,0,1],
		[1,1,1],
	],
	[
		[0,0,1],
		[0,1,1],
		[1,1,0],
	],
	[
		[0,1,0],
		[1,1,1],
		[0,1,0],
	],
	[
		[0,0,1,0],
		[1,1,1,1],
	],
	[
		[1,1,1,1],
		[0,0,1,0],
	],
	[
		[0,1,1],
		[0,1,0],
		[1,1,0],
	],
	[
		[1,1,0],
		[0,1,0],
		[0,1,1],
	],
]

var main_block_array:BlockArray

var current_piece:=-1
var next_piece:=-1

var piece_block_array:BlockArray
var piece_position:=Vector2i(0,0)

var piece_time_to_fall:=1.0
var piece_falling_time:=0.0
var in_soft_drop:=false
var soft_drop_time_counter:=0.0
const SOFT_DROP_TIME:=0.05

const HORIZONTAL_MOVEMENT_START_TIME:=0.2
const HORIZONTAL_MOVEMENT_TIME:=0.05
var horizontal_movement_time_counter:=-HORIZONTAL_MOVEMENT_START_TIME

func _ready() -> void:
	clear_block_map(main_block_map,grid_size)
	clear_block_map(next_piece_block_map,NEXT_PIECE_GRID_SIZE)
	
	main_block_map.global_position=get_viewport().size/2-(
		main_block_map.get_size()+Vector2i(next_piece_block_map.get_size().x,0))/2
	next_piece_block_map.global_position=main_block_map.global_position+Vector2(
		main_block_map.get_size().x,0)
	
	main_block_array=BlockArray.new(grid_size)
	
	current_piece=random_piece()
	next_piece=random_piece()
	set_piece(current_piece)

func _process(_delta: float) -> void:
	var next_piece_block_array:=BlockArray.new(NEXT_PIECE_GRID_SIZE)
	var next_piece_block_array_piece=get_piece_block_array_square(next_piece)
	next_piece_block_array.put(
		next_piece_block_array_piece,
		Vector2i((Vector2(next_piece_block_array.size-next_piece_block_array_piece.size)/2).ceil())
		)
	update_block_map(next_piece_block_map,next_piece_block_array)
	
	
	var block_array=main_block_array.duplicate()
	
	block_array.put(get_piece_shadow(),get_piece_shadow_position())
	
	block_array.put(piece_block_array,piece_position)
	
	update_block_map(main_block_map,block_array)
	
	score_label.text=str(score)

func get_piece_shadow()->BlockArray:
	var shadow:=piece_block_array.duplicate()
	for y in range(shadow.size.y):
		for x in range(shadow.size.x):
			if shadow.types[y][x]!=-1:
				shadow.types[y][x]=-2
	return shadow
	
func get_piece_shadow_position()->Vector2i:
	var p:=piece_position
	if not space_in_map(piece_block_array,p):
		return p
	for i in range(grid_size.y):
		if not space_in_map(piece_block_array,p+Vector2i(0,1)):
			break
		p+=Vector2i(0,1)
	return p

func _physics_process(delta: float) -> void:
	if not space_in_map(piece_block_array,piece_position):
		lose()
	
	if Input.is_action_pressed("move_left"):
		horizontal_movement_time_counter+=delta
		while horizontal_movement_time_counter>=HORIZONTAL_MOVEMENT_TIME:
			horizontal_movement_time_counter-=HORIZONTAL_MOVEMENT_TIME
			piece_move_left()
	elif Input.is_action_pressed("move_right"):
		horizontal_movement_time_counter+=delta
		while horizontal_movement_time_counter>=HORIZONTAL_MOVEMENT_TIME:
			horizontal_movement_time_counter-=HORIZONTAL_MOVEMENT_TIME
			piece_move_right()
	
	var put_piece:=false
	
	if in_soft_drop:
		soft_drop_time_counter+=delta
		
		var time=SOFT_DROP_TIME
		if time>piece_time_to_fall:
			time=piece_time_to_fall
		
		while soft_drop_time_counter>=time:
			soft_drop_time_counter-=time
			if not piece_fall_step():
				put_piece=true
				break
	else:
		piece_falling_time+=delta
	
	if not put_piece:
		while piece_falling_time>=piece_time_to_fall:
			piece_falling_time-=piece_time_to_fall
			if not piece_fall_step():
				put_piece=true
				break
	
	if put_piece:
		piece_put()

func piece_fall_step()->bool:
	if space_in_map(piece_block_array,piece_position+Vector2i(0,1)):
		piece_position.y+=1
		return true
	else:
		return false

func piece_put():
	main_block_array.put(piece_block_array,piece_position)
	current_piece=next_piece
	next_piece=random_piece()
	set_piece(current_piece)
	
	piece_falling_time=0
	in_soft_drop=false
	soft_drop_time_counter=0
	
	check_line_clears()

func check_line_clears():
	var y:=grid_size.y-1
	while y>=0:
		if is_line_full(y):
			clear_line(y)
		else:
			y-=1

func is_line_full(y:int):
	for x in range(grid_size.x):
		if main_block_array.types[y][x]==-1:
			return false
	return true

func clear_line(line_y:int):
	for y in range(line_y,0,-1):
		for x in range(grid_size.x):
			main_block_array.types[y][x]=main_block_array.types[y-1][x]
	for x in range(grid_size.x):
		main_block_array.types[0][x]=-1
	score+=1

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("move_left"):
		piece_move_left()
	if Input.is_action_just_pressed("move_right"):
		piece_move_right()
	
	if Input.is_action_just_released("move_left") or Input.is_action_just_released("move_right"):
		horizontal_movement_time_counter=-HORIZONTAL_MOVEMENT_START_TIME
	
	if Input.is_action_just_pressed("rotate"):
		piece_rotate()
	
	if Input.is_action_pressed("soft_drop"):
		piece_soft_drop()
	else:
		piece_no_soft_drop()
	
	if Input.is_action_just_pressed("hard_drop"):
		piece_hard_drop()

func piece_move_left():
	if space_in_map(piece_block_array,piece_position+Vector2i(-1,0)):
		piece_position.x-=1

func piece_move_right():
	if space_in_map(piece_block_array,piece_position+Vector2i(1,0)):
		piece_position.x+=1

func piece_rotate():
	var piece_rotated:=piece_block_array.rotated_square(1)
	if space_in_map(piece_rotated,piece_position):
		piece_block_array=piece_rotated

func piece_soft_drop():
	in_soft_drop=true

func piece_no_soft_drop():
	in_soft_drop=false
	soft_drop_time_counter=0

func piece_hard_drop():
	for i in range(grid_size.y):
		if not piece_fall_step():
			piece_put()
			break

func space_in_map(piece:BlockArray,position_of_piece:Vector2i)->bool:
	return main_block_array.space_for(piece,position_of_piece)

func set_piece(piece_type:int):
	piece_block_array=get_piece_block_array_square(piece_type)
	@warning_ignore("integer_division")
	piece_position=Vector2i((grid_size.x-piece_block_array.size.x)/2,0)

func random_piece()->int:
	return randi_range(0,PIECE_TYPES.size()-1)

func clear_block_map(block_map,size:Vector2i):
	for y in range(size.y+2):
		for x in range(size.x+2):
			var type:=-1
			if x==0 or x==size.x+1 or y==0 or y==size.y+1:
				type=-3
			block_map.set_block(Vector2i(x,y),type)

func update_block_map(block_map,block_array:BlockArray):
	for y in range(block_array.size.y):
		for x in range(block_array.size.x):
			block_map.set_block(Vector2i(x+1,y+1),block_array.types[y][x])

func get_piece_block_array(piece_type:int)->BlockArray:
	var size:=Vector2i(PIECE_TYPES[piece_type][0].size(),PIECE_TYPES[piece_type].size())
	var block_array:=BlockArray.new(size)
	for y in range(size.y):
		for x in range(size.x):
			if PIECE_TYPES[piece_type][y][x]==1:
				block_array.types[y][x]=piece_type
			else:
				block_array.types[y][x]=-1
	return block_array

func get_piece_block_array_square(piece_type:int)->BlockArray:
	var original:=get_piece_block_array(piece_type)
	var size:=original.size
	if size.x>size.y:
		size.y=size.x
	elif size.y>size.x:
		size.x=size.y
	var block_array=BlockArray.new(size)
	var offset:Vector2i=(size-original.size)/2
	block_array.put(original,offset)
	return block_array

func get_piece_block_array_rotated(piece_type:int,piece_rotation:int)->BlockArray:
	var block_array:=get_piece_block_array_square(piece_type)
	return block_array.rotated_square(piece_rotation)

func lose():
	lost.emit()
