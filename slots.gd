#Ugly solution, but faster than move entire children.
@tool

extends Node2D

@export var sl_oder = [] : set = slots_oder

func set_rest():
	if get_children().size()!=0:
		for i in get_children().size():
			get_child(i).z_index=i

func to_rest():
	if get_children().size()!=0:
		for i in get_child_count():
			get_child(i).z_index=i

func slots_oder(arr=[]):
	if not (sl_oder==arr):
		sl_oder=arr.duplicate();
		to_rest()
		if get_children().size()!=0 && arr.size()!=0 && arr.size()%2==0:
			var buf = get_children();
			for i in range(0,arr.size(),2):
				buf.erase(get_child(arr[i]))
			for i in range(0,arr.size(),2):
				buf.insert(arr[i]+arr[i+1],get_child(arr[i]))
			for i in buf.size():
				buf[i].z_index=i
