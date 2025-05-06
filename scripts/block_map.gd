extends Node2D

const BLOCK_SIZE:=32

var size_in_blocks:=Vector2i(0,0)

func set_block(coords:Vector2i,type:int):
	var atlas_coords=Vector2i(0,0)
	match type:
		-3:
			atlas_coords=Vector2i(1,0)
		-2:
			atlas_coords=Vector2i(2,0)
		-1:
			atlas_coords=Vector2i(0,0)
		_:
			@warning_ignore("integer_division")
			atlas_coords=Vector2i(type%8,1+type/8)
	%TileMapLayer.set_cell(coords,0,atlas_coords)
	if coords.x>=size_in_blocks.x:
		size_in_blocks.x=coords.x+1
	if coords.y>=size_in_blocks.y:
		size_in_blocks.y=coords.y+1

func get_size()->Vector2i:
	return size_in_blocks*BLOCK_SIZE
