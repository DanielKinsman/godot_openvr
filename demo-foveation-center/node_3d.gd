extends Node3D

# For steam frame, requires sharing eye tracking data with PC.
# See https://steamcommunity.com/sharedfiles/filedetails/?id=3822057317&snr=2___

var ovr: XRInterfaceOpenVR


func _ready() -> void:
	ovr = XRServer.find_interface("OpenVR") as XRInterfaceOpenVR
	ovr.interface_is_primary = false
	ovr.application_type = 3 # VRApplication_Background
	if not ovr.initialize():
		print("ate shit!")
		get_tree().quit()

	print(ovr.get_device_battery_percentage(0))


func _process(_delta: float) -> void:
	if Engine.get_process_frames() % 30 == 0:
		print(ovr.get_eye_tracked_foveation_center())
