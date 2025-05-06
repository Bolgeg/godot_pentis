extends Node2D

const NEXT_PIECE_GRID_SIZE:=Vector2i(7,7)
@onready var next_piece_block_map:=%NextPieceBlockMap

var grid_size:=Vector2i(24,20)
@onready var main_block_map:=%MainBlockMap

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

func _process(_delta: float) -> void:
	var next_piece_block_array:=BlockArray.new(NEXT_PIECE_GRID_SIZE)
	var next_piece_block_array_piece=get_piece_block_array_square(next_piece)
	next_piece_block_array.put(
		next_piece_block_array_piece,
		Vector2i((Vector2(next_piece_block_array.size-next_piece_block_array_piece.size)/2).ceil())
		)
	update_block_map(next_piece_block_map,next_piece_block_array)
	
	
	var block_array=main_block_array.duplicate()
	
	update_block_map(main_block_map,block_array)

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
