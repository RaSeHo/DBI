@tool

extends Bone2D
@export var pointB : NodePath : set = point

func point(point):
	pointB = point
	look_at(get_node(pointB).get_global_position())

func _process(delta):
	look_at(get_node(pointB).get_global_position())
