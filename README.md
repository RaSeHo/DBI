# DBI
Faktorian's Solution for DragonBones import to Godot 4. Lightweight and compabile with AnimationTree. Zero new types of nodes.

Unfortunately, AnimationTree in Godot4.0 don't support "Continuous" update-mode for Polygon2D, so you need to bake all animations and change type to "Discrete". Such lovely.

# SCRIPTS SUPPORT:
* Slot contain switch
* Bone animations
* Mesh animations
* zOrder animations
* Dragonbones-IK(only in runtime. Currently.)

# TODO:
- Add mesh blending, like Live2D does.
- Add Smart-Bones, like Moho does.
- Complete support for slot-animations.
- Texture Atlases.
- Fix "servers/rendering/renderer_canvas_cull.cpp:1456 - Condition "pointcount < 3" is true."

# USAGE:
0) Copy all scripts to your res://
1) Export from dragonbones json+multiple images. Script not support textureatlases.
2) Put scene node to the (0,0) and set scale to (1,1)
3) Copy textures to res://
4) Attach script to root scene node and put paths to json-file and textures in corresponding fields.
5) Press checkbox "Import".
