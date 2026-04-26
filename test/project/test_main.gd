extends Node

const QUIT_AFTER_FRAMES := 600

var _frame := 0

func _ready() -> void:
	_setup_2d()
	_setup_xr()

func _setup_2d() -> void:
	# 2D GUI tests — call_gui_input unit tests on regular Controls
	var layer := CanvasLayer.new()
	layer.name = "GUI2D"
	add_child(layer)
	var test = load("res://addons/interaction_system/test/test_interaction_ui.gd").new()
	test.name = "TestInteractionUI"
	layer.add_child(test)

func _setup_xr() -> void:
	# XR viewport — routes poses via lasso query → call_gui_input on canvas plane.
	var xr_interface := XRServer.find_interface("OpenXR")
	if xr_interface == null or not xr_interface.is_initialized():
		return

	get_viewport().use_xr = true

	var origin := XROrigin3D.new()
	origin.name = "XROrigin3D"
	add_child(origin)

	var cam := XRCamera3D.new()
	cam.name = "XRCamera3D"
	origin.add_child(cam)

	# SubViewport renders the 2D UI panel — becomes the canvas plane texture
	var sub_vp := SubViewport.new()
	sub_vp.name = "UIViewport"
	sub_vp.size = Vector2i(1280, 720)
	sub_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(sub_vp)

	var ui_xr = load("res://addons/interaction_system/test/test_interaction_ui.gd").new()
	ui_xr.name = "TestInteractionUIXR"
	sub_vp.add_child(ui_xr)

	# Quad mesh in XR space shows the SubViewport texture (canvas plane)
	var quad := MeshInstance3D.new()
	quad.name = "CanvasPlane"
	var mesh := QuadMesh.new()
	mesh.size = Vector2(1.6, 0.9)
	quad.mesh = mesh
	quad.position = Vector3(0.0, 1.6, -1.5)
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = sub_vp.get_texture()
	mat.flags_unshaded = true
	quad.material_override = mat
	origin.add_child(quad)

	# XR controllers for lasso interaction
	for hand in ["left", "right"]:
		var ctrl := XRController3D.new()
		ctrl.name = "XRController_" + hand
		ctrl.tracker = "/" + hand + "_hand/controller"
		origin.add_child(ctrl)

	# Wire lasso: InteractionManager routes controller pose → lasso query
	# → find nearest Control in sub_vp → call_gui_input.
	# canvas_plane addon not present yet — this branch stays RED until added.
	if ResourceLoader.exists("res://addons/canvas_plane/canvas_plane.gd"):
		var im = load("res://addons/interaction_system/interaction_manager.gd").new()
		im.name = "InteractionManager"
		add_child(im)

func _process(_delta: float) -> void:
	_frame += 1
	if _frame == QUIT_AFTER_FRAMES:
		get_tree().quit()
