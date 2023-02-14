@tool

extends Node2D

@export var default = 0
@export var current = 0 : set = slot_toggle

func slot_toggle(displayIndex):
	for ch in get_child_count():
		if ch == displayIndex:
			get_child(ch).visible=true;
		else:
			get_child(ch).visible=false;
	current=displayIndex
