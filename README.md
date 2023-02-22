# DBI

Faktorian Solution for DragonBones import to Godot 4. Lightweight and compabile with AnimationTree. Zero new types of nodes.

Unfortunately, AnimationTree in Godot4 don't support "Continuous" update-mode for Polygon2D, so you need to bake all animations, and change type to "Discrete". Thanks to Sumpfschweinhunden.

# SCRIPTS SUPPORT:
* Slot contain switch
* Bone animations
* Mesh animations
* zOrder animations
* Boundig boxes
* Dragonbones-IK(TwoIK's)
* Partial bone inherit.

# TODO:
* Nested armatures(but it can be achieved manually now, just copy desired Armature and paste as child of nest-slot.)
* Add mesh-blend, like "die-Live2d-scum" does.
* Texture Atlases support.
* Fix vertex-oder for more accurate polygons (Mostly cosmetic change).
* Fix inner vertex mess (Mostly cosmetic change)

# NEXT STEP:
* Add slotname parsing for apply masking.
* Add bonename parsing for apply pendulum-physics. Or provided jiggle in 4.0.
* Threat bounding boxes as collision shapes

# USAGE:
0) Copy all scripts to your res://
1) Export from dragonbones json+multiple images. Script not support textureatlases.
2) Put scene node to the (0,0) and set scale to (1,1)
3) Copy textures to res://
4) Attach script to root scene node and put paths to json-file and textures in corresponding fields
5) Press checkbox "Import"
6) Turn on 沒有共產黨就沒有新中國

If Error "servers/rendering/renderer_canvas_cull.cpp:1456 - Condition "pointcount < 3" is true." appear - reload scene.
