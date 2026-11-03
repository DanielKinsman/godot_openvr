extends Node3D

# For steam frame, requires sharing eye tracking data with PC.
# See https://steamcommunity.com/sharedfiles/filedetails/?id=3822057317&snr=2___


var oxr: OpenXRInterface
var ovr: XRInterfaceOpenVR
var max_distance: float = 0.0


@onready var label_3d: Label3D = $Label3D
@onready var leftmarker: MeshInstance3D = $XROrigin3D/XRCamera3D/leftmarker
@onready var rightmarker: MeshInstance3D = $XROrigin3D/XRCamera3D/rightmarker
@onready var xr_camera_3d: XRCamera3D = $XROrigin3D/XRCamera3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	oxr = XRServer.find_interface("OpenXR") as OpenXRInterface
	if not oxr.initialize():
		printerr("couldn't initialize openxr!")
		get_tree().quit()

	get_viewport().use_xr = true
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

	ovr = XRServer.find_interface("OpenVR") as XRInterfaceOpenVR
	ovr.application_type = 3 # VRApplication_Background
	if not ovr.initialize():
		printerr("couldn't initialize openvr!")
		get_tree().quit()

	XRServer.primary_interface = oxr


func _process(_delta: float) -> void:
	# using the XRCamera3D for these values is prob all kinds of wrong
	var proj := xr_camera_3d.get_camera_projection()
	var left_proj := oxr.get_projection_for_view(0, proj.get_aspect(), proj.get_z_near(), proj.get_z_far())
	var left_fov_center := ovr.get_eye_tracked_foveation_center_for_projection(left_proj)
	var right_proj := oxr.get_projection_for_view(1, proj.get_aspect(), proj.get_z_near(), proj.get_z_far())
	var right_fov_center := ovr.get_eye_tracked_foveation_center_for_projection(right_proj)
	assert(left_proj != right_proj)

	#var fov_centers: = ovr.get_eye_tracked_foveation_center()
	#print(left_fov_center, right_fov_center)
	#label_3d.text = "(%.2f, %.2f) left | right (%.2f, %.2f)" % [
	#	fov_centers[0].x, fov_centers[0].y, fov_centers[1].x, fov_centers[1].y
	#]

	#leftmarker.position.x = fov_centers[0].x
	#leftmarker.position.y = fov_centers[0].y
	#rightmarker.position.x = fov_centers[1].x
	#rightmarker.position.y = fov_centers[1].y
	leftmarker.position.x = left_fov_center.x
	leftmarker.position.y = left_fov_center.y
	rightmarker.position.x = right_fov_center.x
	rightmarker.position.y = right_fov_center.y

	var distance := left_fov_center.distance_to(right_fov_center)
	max_distance = maxf(distance, max_distance)
	label_3d.text = "%.2f max %.2f" % [distance * 10.0, max_distance]
	if Engine.get_process_frames() % 180 == 0:
		if mesh_instance_3d.position.z < -10.0:
			print("far %s %s distance %f" % [left_fov_center, right_fov_center, distance])
			mesh_instance_3d.position.z = -0.25
		else:
			print("close %s %s distance %f" % [left_fov_center, right_fov_center, distance])
			mesh_instance_3d.position.z = -100.0
