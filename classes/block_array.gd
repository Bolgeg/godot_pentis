class_name BlockArray
extends RefCounted

var size:=Vector2i(0,0)
var types:=[]

func _init(size_to_set:Vector2i) -> void:
	size=size_to_set
	for y in range(size.y):
		types.append([])
		for x in range(size.x):
			types[-1].append(-1)

func duplicate()->BlockArray:
	var block_array=new(size)
	block_array.types=types.duplicate(true)
	return block_array

func put(block_array:BlockArray,offset:Vector2i):
	for y in range(block_array.size.y):
		for x in range(block_array.size.x):
			var p:Vector2i=offset+Vector2i(x,y)
			if p.x>=0 and p.y>=0 and p.x<size.x and p.y<size.y:
				if block_array.types[y][x]!=-1:
					types[p.y][p.x]=block_array.types[y][x]

func rotated_90_square()->BlockArray:
	var block_array=new(size)
	for y in range(size.y):
		for x in range(size.x):
			block_array.types[y][x]=types[size.y-1-x][y]
	return block_array

func rotated_square(rotation:int)->BlockArray:
	var rotation_times=rotation%4
	if rotation_times<0:
		rotation_times+=4
	var block_array=duplicate()
	for iteration in range(rotation_times):
		block_array=block_array.rotated_90_square()
	return block_array
