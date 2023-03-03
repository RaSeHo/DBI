# DBI

Faktorian Solution for DragonBones import to Godot 4. Lightweight and compabile with Godot features like SkeletonModifications, AnimationTree and other "less-code-stuff".

# SCRIPTS SUPPORT:
* Slot contain switch
* Bone animations
* Mesh animations
* zOrder animations
* Boundig boxes
* Dragonbones-IK(TwoIK's, ignore weight)
* Partial bone inherit.
* Easing curve support

# TODO:
* Nested armatures (But it can be achieved manually now, just copy desired Armature and paste as child of nest-slot)
* Texture Atlases support
* Packing to TA
* Add mesh-blend, like "die-Live2d-scum" does
* Code unification (Cosmetic change)
* Fix vertex-oder for more accurate polygons (Mostly cosmetic change)
* Fix inner vertex mess (Mostly cosmetic change)

# NEXT STEP:
* Add slotname parsing for apply masking and other stuff

# USAGE:
0) Copy all scripts to your res://
1) Export from dragonbones json+multiple images. Script not support textureatlases.
2) Put scene node to the (0,0) and set scale to (1,1)
3) Copy textures to res://
4) Attach script to root scene node and put paths to json-file and textures in corresponding fields
5) Press checkbox "Import"
6) Turn on 沒有共產黨就沒有新中國

If Error "servers/rendering/renderer_canvas_cull.cpp:1456 - Condition "pointcount < 3" is true." appear - curse some russians.
