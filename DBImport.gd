#Faktorian Solution for DragonBones

@tool
extends Node2D

@export_global_file("*.json") var jsonpath = "";
@export_global_dir var textpath = "";
@export var import : bool = false : set = dbimport
@export var bake : bool = false

func bake(AL):
	pass;

func set_texture(node, path = ""):
	if path=="":
		path=node.name
	var dir = DirAccess.open(textpath+"/"+path.get_base_dir())
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif (not file.begins_with(".")) && (file.get_basename() == path.get_file().get_basename()):
			if path.get_base_dir().length()==0:
				node.set_texture(load(textpath+"/"+file))
			else:
				node.set_texture(load(textpath+"/"+path.get_base_dir()+"/"+file))
	dir.list_dir_end()

func dbimport(val):
	if jsonpath == "" || textpath == "":
		import=false;
		return;
	if !val:
		return;
	val=false;

	var file = FileAccess.open(jsonpath, FileAccess.READ)
	if file == null :
		return;
	var test_json_conv = JSON.new()
	test_json_conv.parse(file.get_as_text())	
	var json_result = test_json_conv.get_data()
	file = null

	#Skeleton2D build
	for i in json_result.armature.size():
		var true_vertex_oder_dict = {}

		var skeleton = Skeleton2D.new();
		skeleton.set_name(json_result.armature[i].name);
		self.add_child(skeleton);
		skeleton.owner = get_tree().edited_scene_root;

		if json_result.armature[i].has("bone"):
			for b in json_result.armature[i].bone.size():
				var bone = Bone2D.new();
				if json_result.armature[i].bone[b].has("parent"):
					var par = skeleton.find_child(json_result.armature[i].bone[b].parent)
					var pointB = Vector2(0,0);
					var sx = 1;
					var sy = 1;
					if json_result.armature[i].bone[b].has("transform"):
						if json_result.armature[i].bone[b].transform.has('x'):
							pointB.x= json_result.armature[i].bone[b].transform.x
						if json_result.armature[i].bone[b].transform.has('y'):
							pointB.y= json_result.armature[i].bone[b].transform.y
						if json_result.armature[i].bone[b].transform.has("scX"):
							sx = json_result.armature[i].bone[b].transform.scX;
						if json_result.armature[i].bone[b].transform.has("scY"):
							sx = json_result.armature[i].bone[b].transform.scX;
					par.add_child(bone);
					if json_result.armature[i].bone[b].has("transform"):
						if json_result.armature[i].bone[b].transform.has("skX"):
							bone.set_rotation_degrees(json_result.armature[i].bone[b].transform.skX)
						if json_result.armature[i].bone[b].transform.has("skY"):
							bone.set_rotation_degrees(json_result.armature[i].bone[b].transform.skY)
					bone.set_name(json_result.armature[i].bone[b].name);
					bone.apply_scale(Vector2(sx,sy))
					bone.set_length(0)
					if json_result.armature[i].bone[b].has("length"):
						bone.set_length(json_result.armature[i].bone[b].length)
					bone.owner = get_tree().edited_scene_root
					bone.set_position(pointB);
				else:
					bone.set_name(json_result.armature[i].bone[b].name);
					bone.set_default_length(0);
					var origin = Vector2(0,0);
					if json_result.armature[i].bone[b].has("transform"):
						if json_result.armature[i].bone[b].transform.has("x") :
							origin.x=json_result.armature[i].bone[b].transform.x;
						if json_result.armature[i].bone[b].transform.has("y") :
							origin.y=json_result.armature[i].bone[b].transform.y;
					bone.set_position(origin);
					skeleton.add_child(bone)
					bone.owner = get_tree().edited_scene_root
				bone.rest=bone.transform

		if json_result.armature[i].has("slot"):
			var masterslot = Node2D.new()
			var slotscript = load("res://slots.gd")
			masterslot.set_script(slotscript)
			masterslot.set_name("SLOTS")

			skeleton.add_child(masterslot)
			masterslot.owner = get_tree().edited_scene_root
			
			for sl in json_result.armature[i].slot.size():
				var slot = Node2D.new();
				slot.set_name(json_result.armature[i].slot[sl].name)
				true_vertex_oder_dict[json_result.armature[i].slot[sl].name] = {}
				if json_result.armature[i].slot[sl].has("color"):
					var C = Color(1,1,1,1);
					if json_result.armature[i].slot[sl].color.has("aM"):
						C.a=json_result.armature[i].slot[sl].color.aM/100
					if json_result.armature[i].slot[sl].color.has("rM"):
						C.r=json_result.armature[i].slot[sl].color.rM/100
					if json_result.armature[i].slot[sl].color.has("gM"):
						C.g=json_result.armature[i].slot[sl].color.gM/100
					if json_result.armature[i].slot[sl].color.has("bM"):
						C.b=json_result.armature[i].slot[sl].color.bM/100
					slot.set_modulate(C)
				masterslot.add_child(slot);
				slot.owner = get_tree().edited_scene_root
			for sl in json_result.armature[i].slot.size():
				if(json_result.armature[i].slot[sl].has("displayIndex")):
					masterslot.slot_order(sl,json_result.armature[i].slot[sl].displayIndex)
			masterslot.set_rest()

			var slots = masterslot.get_children();
			slotscript = load("res://slot.gd")
			for sl in slots.size():
				slots[sl].set_script(slotscript)
				if json_result.armature[i].slot[sl].has("displayIndex"):
					slots[sl].default = json_result.armature[i].slot[sl].displayIndex
					slots[sl].current = json_result.armature[i].slot[sl].displayIndex
				else:
					slots[sl].default = 0
					slots[sl].current = 0

			for j in json_result.armature[i].skin.size():
				for k in json_result.armature[i].skin[j].slot.size():
					if json_result.armature[i].skin[j].slot[k].has("display"):
						var display;
						for d in json_result.armature[i].skin[j].slot[k].display.size():
							if json_result.armature[i].skin[j].slot[k].display[d].has("type"):
								if json_result.armature[i].skin[j].slot[k].display[d].type == "mesh" || json_result.armature[i].skin[j].slot[k].display[d].type == "boundingBox" :
									var display_json = json_result.armature[i].skin[j].slot[k].display[d]
									display = Polygon2D.new();
									var s_name = json_result.armature[i].skin[j].slot[k].display[d].name
									if s_name.rfind("/")!=-1:
										s_name = s_name.substr(s_name.rfind("/")+1)
									display.set_name(s_name)

									if(json_result.armature[i].skin[j].slot[k].display[d].has("path")):
										set_texture(display,json_result.armature[i].skin[j].slot[k].display[d].path)
									else:
										set_texture(display,json_result.armature[i].skin[j].slot[k].display[d].name)

									var true_oder = PackedVector2Array()

									for v in range(0,display_json.vertices.size(),2):
										true_oder.push_back(Vector2(display_json.vertices[v],display_json.vertices[v+1]));

									var points2 = PackedVector2Array();
									for p in range(0,display_json.edges.size()-1,2):
										points2.push_back(true_oder[display_json.edges[p]])
									var internal = true_oder.size()-points2.size();

									if true_oder.size() >= display_json.edges.max()+1:
										for p in true_oder.size():
											if points2.find(true_oder[p])==-1:
												points2.push_back(true_oder[p]);
									display.set_polygon(points2);

									if display_json.type == "mesh":
										display.set_internal_vertex_count(internal);
										var triangles = [];
										for v in range(0,display_json.triangles.size(),3):
											var true_1 = display.polygon.find(true_oder[display_json.triangles[v]])
											var true_2 = display.polygon.find(true_oder[display_json.triangles[v+1]])
											var true_3 = display.polygon.find(true_oder[display_json.triangles[v+2]])
											triangles.push_back(PackedInt32Array([true_1,true_2,true_3]))

										display.set_polygons(triangles);
										if display_json.has("uvs"):
											var uvs = PackedVector2Array();
											uvs.resize(display.polygon.size())
											var iter = 0;
											for v in range(0,display_json.uvs.size(),2):
												var true_1 = display.polygon.find(true_oder[iter])
												uvs[true_1]=Vector2(display_json.width*display_json.uvs[v],display_json.height*display_json.uvs[v+1]);
												iter += 1
											display.set_uv(uvs);

										if json_result.armature[i].skin[j].slot[k].display[d].has("weights"):
											var arr = json_result.armature[i].skin[j].slot[k].display[d].weights;
											var bones = {}
											var index = 0;
											var vert_num = 0;
											while index<arr.size():
												var affected=arr[index]*2
												for w_bone in range(1,affected,2):
													var bone_path=skeleton.find_child(json_result.armature[i].bone[arr[index+w_bone]].name).get_path();
													if not (bones.has(bone_path)):
														bones[bone_path] = [];
														bones[bone_path].resize(display.polygon.size())
													bones[bone_path][display.polygon.find(true_oder[vert_num])]=arr[index+w_bone+1]
												index+=(arr[index]*2)+1
												vert_num+=1
											for wb in bones.keys().size():
												display.add_bone(bones.keys()[wb],bones[bones.keys()[wb]])

										else:
											for sl in json_result.armature[i].slot.size():
												if json_result.armature[i].slot[sl].name==json_result.armature[i].skin[j].slot[k].name:
													var bone_path = skeleton.find_child(json_result.armature[i].slot[sl].parent).get_path();
													var wbone = []
													wbone.resize(display.polygon.size());
													wbone.fill(1.0)
													display.add_bone(bone_path,wbone);
											display.set_skeleton(skeleton.get_path())
										
										var trans = Transform2D()

										skeleton.find_child("SLOTS",false).find_child(json_result.armature[i].skin[j].slot[k].name,false).add_child(display)
										if json_result.armature[i].skin[j].slot[k].display[d].has("weights"):
											display.position=Vector2(0,0)
										else:
											for sl in json_result.armature[i].slot.size():
												if json_result.armature[i].slot[sl].name==json_result.armature[i].skin[j].slot[k].name:
													var vec = PackedVector2Array();
													for p in display.polygon.size():
														trans = skeleton.find_child(json_result.armature[i].slot[sl].parent).get_global_transform()
														vec.push_back(trans*display.polygon[p])
													display.set_polygon(vec);
													vec.clear();

										display.set_skeleton(skeleton.get_path())
										if(json_result.armature[i].skin[j].slot[k].display[d].has("path")):
											set_texture(display,json_result.armature[i].skin[j].slot[k].display[d].path)
										else:
											set_texture(display)
										display.owner = get_tree().edited_scene_root
										true_vertex_oder_dict[json_result.armature[i].skin[j].slot[k].name][display.name]={"oder" : true_oder, "edges" : display_json.edges, "transformation" : trans}

									elif display_json.type == "boundingBox":

										for sl in json_result.armature[i].slot.size():
											display.transform=skeleton.find_child(json_result.armature[i].slot[sl].parent).get_global_transform()
											if json_result.armature[i].slot[sl].name==json_result.armature[i].skin[j].slot[k].name:
												var bone_path = skeleton.find_child(json_result.armature[i].slot[sl].parent).get_path();
												var bone_weights = []
												for bw in display.polygon.size():
													bone_weights.push_back(1);
												display.add_bone(bone_path,bone_weights);
										skeleton.find_child("SLOTS",false).find_child(json_result.armature[i].skin[j].slot[k].name,false).add_child(display)
										display.set_skeleton(skeleton.get_path())

										display.owner = get_tree().edited_scene_root
								if json_result.armature[i].skin[j].slot[k].display[d].type == "armature":
									pass

							else:
								display = Sprite2D.new()
								display.set_name(json_result.armature[i].skin[j].slot[k].display[d].name);

								if json_result.armature[i].skin[j].slot[k].display[d].has("transform"):
									display.position=Vector2(0,0)
									if json_result.armature[i].skin[j].slot[k].display[d].transform.has("x"):
										display.position.x=json_result.armature[i].skin[j].slot[k].display[d].transform.x
									if json_result.armature[i].skin[j].slot[k].display[d].transform.has("y"):
										display.position.y=json_result.armature[i].skin[j].slot[k].display[d].transform.y

								var pol = Polygon2D.new()
								var s_name = json_result.armature[i].skin[j].slot[k].display[d].name
								if s_name.rfind("/")!=-1:
									s_name = s_name.substr(s_name.rfind("/")+1)
								pol.set_name(s_name)

								if(json_result.armature[i].skin[j].slot[k].display[d].has("path")):
									set_texture(display,json_result.armature[i].skin[j].slot[k].display[d].path)
								else:
									set_texture(display,json_result.armature[i].skin[j].slot[k].display[d].name)
								pol.set_texture(display.get_texture())

								var vec = PackedVector2Array();
								var uvs = PackedVector2Array();

								vec.push_back(display.get_rect().position)
								vec.push_back(Vector2(display.get_rect().position.x+display.get_rect().size.x,display.get_rect().position.y))
								vec.push_back(Vector2(display.get_rect().position.x+display.get_rect().size.x,display.get_rect().position.y+display.get_rect().size.y))
								vec.push_back(Vector2(display.get_rect().position.x,display.get_rect().position.y+display.get_rect().size.y))
								pol.set_polygon(vec)

								uvs.push_back(Vector2(0,0))
								uvs.push_back(Vector2(display.get_rect().size.x,0))
								uvs.push_back(Vector2(display.get_rect().size.x,display.get_rect().size.y))
								uvs.push_back(Vector2(0,display.get_rect().size.y))
								pol.set_uv(uvs)

								var p_bone;

								for sl in json_result.armature[i].slot.size():
									if json_result.armature[i].slot[sl].name==json_result.armature[i].skin[j].slot[k].name:
										p_bone = skeleton.find_child(json_result.armature[i].slot[sl].parent)
										break;

								skeleton.find_child("SLOTS",false).find_child(json_result.armature[i].skin[j].slot[k].name,false).add_child(pol)
								pol.get_parent().global_transform=display.transform

								pol.global_position=Vector2(0,0);
								var vc = PackedVector2Array();
								for p in pol.polygon.size():
									vc.push_back(display.transform*pol.polygon[p])
								pol.set_polygon(vc);

								if json_result.armature[i].skin[j].slot[k].display[d].has("transform"):
									if json_result.armature[i].skin[j].slot[k].display[d].transform.has("skX"):
										pol.get_parent().set_rotation_degrees((json_result.armature[i].skin[j].slot[k].display[d].transform.skX))
									if json_result.armature[i].skin[j].slot[k].display[d].transform.has("scX"):
										pol.get_parent().scale.x=json_result.armature[i].skin[j].slot[k].display[d].transform.scX
									if json_result.armature[i].skin[j].slot[k].display[d].transform.has("scY"):
										pol.get_parent().scale.y=json_result.armature[i].skin[j].slot[k].display[d].transform.scY
								pol.get_parent().global_transform=p_bone.get_global_transform()*pol.get_parent().global_transform

								var remote = RemoteTransform2D.new()
								remote.set_name(pol.get_parent().name)
								p_bone.add_child(remote);
								remote.set_global_transform(pol.get_parent().get_global_transform());
								remote.remote_path=pol.get_parent().get_path()

								pol.set_skeleton(skeleton.get_path())
								
								remote.owner = get_tree().edited_scene_root
								pol.owner = get_tree().edited_scene_root

		if json_result.armature[i].has("ik"):
			var ikscript = load("res://IK.gd")
			for ik in json_result.armature[i].ik.size():
				var bone = skeleton.find_child(json_result.armature[i].ik[ik].bone)
				bone.set_script(ikscript)
				bone.pointB=bone.get_path_to(find_child(json_result.armature[i].ik[ik].target))

		if not json_result.armature[i].has("animation"):
			return
		var AP = AnimationPlayer.new()
		AP.set_name("Animation")
		AP.set_root(skeleton.get_path())
		skeleton.add_child(AP)
		AP.owner = get_tree().edited_scene_root
		var AL = AnimationLibrary.new()
		for an in json_result.armature[i].animation.size():
			var animation = Animation.new()
			var length=0
			var framerate = 1/json_result.armature[i].frameRate
			if json_result.armature[i].animation[an].has("bone"):
				for bi in json_result.armature[i].animation[an].bone.size():

					if json_result.armature[i].animation[an].bone[bi].has("translateFrame"):
						var bone_position = skeleton.find_child(json_result.armature[i].animation[an].bone[bi].name).position
						var write_head=0;
						var track_pos_index = animation.add_track(Animation.TYPE_VALUE)
						animation.track_set_path(track_pos_index, String(skeleton.get_path_to(skeleton.find_child(json_result.armature[i].animation[an].bone[bi].name)))+":position")
						for f in json_result.armature[i].animation[an].bone[bi].translateFrame.size():
							var newPos = bone_position
							if  json_result.armature[i].animation[an].bone[bi].translateFrame[f].has("x"):
								newPos.x+=json_result.armature[i].animation[an].bone[bi].translateFrame[f].x
							if  json_result.armature[i].animation[an].bone[bi].translateFrame[f].has("y"):
								newPos.y+=json_result.armature[i].animation[an].bone[bi].translateFrame[f].y
							animation.track_insert_key(track_pos_index, write_head, newPos)
							if json_result.armature[i].animation[an].bone[bi].translateFrame[f].has("duration") :
								write_head+=json_result.armature[i].animation[an].bone[bi].translateFrame[f].duration*framerate
						if length<write_head:
							length=write_head

					if json_result.armature[i].animation[an].bone[bi].has("rotateFrame"):
						var bone_rot = skeleton.find_child(json_result.armature[i].animation[an].bone[bi].name).rotation_degrees
						var track_rot_index = animation.add_track(Animation.TYPE_VALUE)
						animation.track_set_path(track_rot_index, String(skeleton.get_path_to(skeleton.find_child(json_result.armature[i].animation[an].bone[bi].name)))+":rotation_degrees")
						var write_head=0;
						for f in json_result.armature[i].animation[an].bone[bi].rotateFrame.size():
							var newRot = bone_rot
							if  json_result.armature[i].animation[an].bone[bi].rotateFrame[f].has("rotate"):
								newRot += json_result.armature[i].animation[an].bone[bi].rotateFrame[f].rotate
							animation.track_insert_key(track_rot_index, write_head, newRot)
							write_head+=json_result.armature[i].animation[an].bone[bi].rotateFrame[f].duration*framerate
						if length<write_head:
							length=write_head

					if json_result.armature[i].animation[an].bone[bi].has("scaleFrame"):
						var s_scale = skeleton.find_child(json_result.armature[i].animation[an].bone[bi].name).scale
						var track_scale_index = animation.add_track(Animation.TYPE_VALUE)
						animation.track_set_path(track_scale_index, String(skeleton.get_path_to(skeleton.find_child(json_result.armature[i].animation[an].bone[bi].name)))+":scale")
						var write_head=0;
						for f in json_result.armature[i].animation[an].bone[bi].scaleFrame.size():
							var newScale = s_scale
							if  json_result.armature[i].animation[an].bone[bi].scaleFrame[f].has("x"):
								newScale.x = json_result.armature[i].animation[an].bone[bi].scaleFrame[f].x
							if  json_result.armature[i].animation[an].bone[bi].scaleFrame[f].has("y"):
								newScale.y = json_result.armature[i].animation[an].bone[bi].scaleFrame[f].y
							animation.track_insert_key(track_scale_index, write_head, newScale)
							write_head+=json_result.armature[i].animation[an].bone[bi].scaleFrame[f].duration*framerate
						if length<write_head:
							length=write_head

			if json_result.armature[i].animation[an].has("ffd"):
				for ffdi in json_result.armature[i].animation[an].ffd.size():
					var track_ffd_index = animation.add_track(Animation.TYPE_VALUE)
					var f_name = json_result.armature[i].animation[an].ffd[ffdi].name

					if f_name.rfind("/")!=-1:
						f_name = f_name.substr(f_name.rfind("/")+1)

					animation.track_set_path(track_ffd_index, String(skeleton.get_path_to(skeleton.find_child("SLOTS",false).find_child(json_result.armature[i].animation[an].ffd[ffdi].slot,false).find_child(f_name)))+":polygon")

					if json_result.armature[i].animation[an].ffd[ffdi].has("frame"):
						var write_head=0;
						for f in json_result.armature[i].animation[an].ffd[ffdi].frame.size():
							var offset=0
							var nextvec = true_vertex_oder_dict[json_result.armature[i].animation[an].ffd[ffdi].slot][f_name].oder.duplicate()

							if json_result.armature[i].animation[an].ffd[ffdi].frame[f].has("offset"):
								offset = json_result.armature[i].animation[an].ffd[ffdi].frame[f].offset
							
							if json_result.armature[i].animation[an].ffd[ffdi].frame[f].has("vertices"):

								var vert_arr = []

								for v in nextvec.size():
									vert_arr.push_back(nextvec[v].x)
									vert_arr.push_back(nextvec[v].y)

								for v in json_result.armature[i].animation[an].ffd[ffdi].frame[f].vertices.size():
									vert_arr[offset]+=json_result.armature[i].animation[an].ffd[ffdi].frame[f].vertices[v]
									offset+=1

								nextvec.clear();

								for v in range(0,vert_arr.size(),2):
									nextvec.push_back(Vector2(vert_arr[v],vert_arr[v+1]))

							var keyframe = PackedVector2Array()
							var edges = true_vertex_oder_dict[json_result.armature[i].animation[an].ffd[ffdi].slot][f_name].edges;
							var trans = true_vertex_oder_dict[json_result.armature[i].animation[an].ffd[ffdi].slot][f_name].transformation

							for p in range(0,edges.size()-1,2):
								keyframe.push_back(trans*nextvec[edges[p]])
							for p in nextvec.size():
								if not edges.has(float(p)):
									keyframe.push_back(trans*nextvec[p])

							animation.track_insert_key(track_ffd_index, write_head, keyframe)
							write_head+=json_result.armature[i].animation[an].ffd[ffdi].frame[f].duration*framerate

						if length<write_head:
							length=write_head

			if json_result.armature[i].animation[an].has("slot"):
				for sl in json_result.armature[i].animation[an].slot.size():
					var slot = skeleton.find_child(json_result.armature[i].animation[an].slot[sl].name)
					var write_head=0;
					var track_slot_index = animation.add_track(Animation.TYPE_VALUE)
					animation.value_track_set_update_mode(track_slot_index,Animation.UPDATE_DISCRETE)
					animation.track_set_path(track_slot_index, String(skeleton.get_path_to(slot))+":current");
					if json_result.armature[i].animation[an].slot[sl].has("displayFrame"):
						for frame in json_result.armature[i].animation[an].slot[sl].displayFrame.size():
							var value = 0;
							if json_result.armature[i].animation[an].slot[sl].displayFrame[frame].has("value"):
								value = json_result.armature[i].animation[an].slot[sl].displayFrame[frame].value
							animation.track_insert_key(track_slot_index, write_head, value)
							write_head+=json_result.armature[i].animation[an].slot[sl].displayFrame[frame].duration*framerate
					if length<write_head:
						length=write_head

			if json_result.armature[i].animation[an].has("zOrder"):
				if json_result.armature[i].animation[an].zOrder.has("frame"):
					var slots = skeleton.find_child("SLOTS")
					var track_slot_index = animation.add_track(Animation.TYPE_VALUE)
					animation.value_track_set_update_mode(track_slot_index,Animation.UPDATE_DISCRETE)
					animation.track_set_path(track_slot_index, String(skeleton.get_path_to(slots))+":sl_oder");
					var write_head=0
					for frame in json_result.armature[i].animation[an].zOrder.frame.size():
						var arr = []
						if json_result.armature[i].animation[an].zOrder.frame[frame].has("zOrder"):
							arr = json_result.armature[i].animation[an].zOrder.frame[frame].zOrder
						animation.track_insert_key(track_slot_index, write_head, arr)
						write_head+=json_result.armature[i].animation[an].zOrder.frame[frame].duration*framerate
					if length<write_head:
						length=write_head

			animation.set_length(length);
			AL.add_animation(json_result.armature[i].animation[an].name, animation)
#Add RESET animation...
		var animation = Animation.new()
		AL.add_animation("RESET", animation)
		if bake:
			bake(AL)
		AP.add_animation_library("Animations", AL)
