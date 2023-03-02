@tool
extends Polygon2D

@export var start : PackedVector2Array
@export var end : PackedVector2Array

@export var delta : float = 0 : set = curv

func curv(del):
	for i in polygon.size():
		polygon[i]=lerp(start[i],end[i],del);
