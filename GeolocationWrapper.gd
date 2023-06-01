extends Node

#class_name GeolocationWrapperGDScript
# enums
enum platforms {
	iOS,
	android,
	other
}

enum geolocation_authorization_status {
	PERMISSION_STATUS_UNKNOWN = 1 << 0,
	PERMISSION_STATUS_DENIED = 1 << 1,
	PERMISSION_STATUS_ALLOWED = 1 << 2
}

enum geolocation_desired_accuracy_constants {
	ACCURACY_BEST_FOR_NAVIGATION = 1 << 0,
	ACCURACY_BEST = 1 << 1,
	ACCURACY_NEAREST_TEN_METERS = 1 << 2,
	ACCURACY_HUNDRED_METERS = 1 << 3,
	ACCURACY_KILOMETER = 1 << 4,
	ACCURACY_THREE_KILOMETER = 1 << 5,
	ACCURACY_REDUCED = 1 << 6
}

enum geolocation_error_codes {
	ERROR_DENIED = 1 << 0,
	ERROR_NETWORK = 1 << 1,
	ERROR_HEADING_FAILURE = 1 << 2
	ERROR_LOCATION_UNKNOWN = 1 << 3
	ERROR_TIMEOUT = 1 << 4
	ERROR_UNSUPPORTED = 1 << 5
	ERROR_LOCATION_DISABLED = 1 << 6
	ERROR_UNKNOWN = 1 << 7
}

# signals
signal authorization_changed(status)
signal error(code)
signal debug(message, number)
signal location_update(location_data)
signal heading_update(heading_data)
signal location_capability_result(capable)

# stuff

var platform
var _geolocation_plugin:Object
var _last_android_permission_signal:int = -1;

var supported:bool = false
var _last_error:int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_determine_platform()
	if platform == platforms.iOS or platform == platforms.android:
		_setup_native_plugin()

func _determine_platform():
	var os_name = OS.get_name() 
	match os_name:
		"Android": platform = platforms.android
		"iOS": platform = platforms.iOS
		_: platform = platforms.other
	
func _setup_native_plugin():
	if Engine.has_singleton("Geolocation"):
		_on_log("plugin found")
		_geolocation_plugin = Engine.get_singleton("Geolocation")
		supported = true
		
		if platform == platforms.iOS:
			_geolocation_plugin.connect("authorization_changed", self, "_on_authorization_changed")
	
		if platform == platforms.android:
			get_tree().connect("on_request_permissions_result", self, "_on_godot_android_permissions")
			
		_geolocation_plugin.connect("error", self, "_on_error")
		_geolocation_plugin.connect("log", self, "_on_log")
		_geolocation_plugin.connect("location_update", self, "_on_location_update")
		_geolocation_plugin.connect("heading_update", self, "_on_heading_update")
		_geolocation_plugin.connect("location_capability_result", self, "_on_location_capability_result")
		
	else:
		_on_log("No singleton")
		
# handle/wrap android permisson signals
		
func _on_godot_android_permissions(permission:String, granted:bool):
	if _last_android_permission_signal == -1:
		_last_android_permission_signal = OS.get_ticks_msec()
	else:
		var time_diff:int = OS.get_ticks_msec() - _last_android_permission_signal
		_last_android_permission_signal = -1
		if time_diff < 500:
			return
	if permission == "android.permission.ACCESS_COARSE_LOCATION" && granted:
		_on_authorization_changed(geolocation_authorization_status.PERMISSION_STATUS_ALLOWED)
		return
	if permission == "android.permission.ACCESS_FINE_LOCATION" && granted:
		_on_authorization_changed(geolocation_authorization_status.PERMISSION_STATUS_ALLOWED)
		return
	
	_on_authorization_changed(geolocation_authorization_status.PERMISSION_STATUS_DENIED)

# methods
# permissions
func request_permissions():
	if supports("request_permission"):
		_geolocation_plugin.request_permission()
		return
	
	if platform == platforms.android:
		OS.request_permissions()

# location
func request_location():
	_geolocation_plugin.request_location()

func start_updating_location():
	_geolocation_plugin.start_updating_location()

func stop_updating_location():
	_geolocation_plugin.stop_updating_location()

# magnetic heading


# status
func authorization_status() -> int:
	return _geolocation_plugin.authorization_status()

func allows_full_accuracy() -> bool:
	return _geolocation_plugin.allows_full_accuracy()

func can_request_permissions() -> bool:
	return _geolocation_plugin.can_request_permissions()

func is_updating_location() -> bool:
	return _geolocation_plugin.is_updating_location()

func should_show_permission_requirement_explanation() -> bool:
	return _geolocation_plugin.should_show_permission_requirement_explanation()
	
func request_location_capabilty():
	_geolocation_plugin.request_location_capabilty()
	
func should_check_location_capability() ->bool:
	return _geolocation_plugin.should_check_location_capability()

# supported methods
func supports(method_name:String) ->bool:
	return _geolocation_plugin.supports(method_name)

# options
func set_distance_filter(meters:float):
	_geolocation_plugin.set_distance_filter(meters)

func set_desired_accuracy(desired_accuracy_constant:int):
	_geolocation_plugin.set_desired_accuracy(desired_accuracy_constant)

func set_update_interval(seconds:int):
	_geolocation_plugin.set_update_interval(seconds)

func set_max_wait_time(seconds:int):
	_geolocation_plugin.set_max_wait_time(seconds)
	
func set_return_string_coordinates(active:bool):
	_geolocation_plugin.set_return_string_coordinates(active)
	
func set_failure_timeout(seconds:int):
	_geolocation_plugin.set_failure_timeout(seconds)

func set_debug_log_signal(send:bool):
	_geolocation_plugin.set_debug_log_signal(send)
	
func set_auto_check_location_capability(auto:bool):
	_geolocation_plugin.set_auto_check_location_capability(auto)

# plugin signals
func _on_log(message :String, number:float = 0):
	emit_signal("debug", message, number)

func _on_error(code:int):
	_last_error = code
	emit_signal("error", code)

func _on_authorization_changed(status:int):
	emit_signal("authorization_changed", status)

func _on_location_update(location_data:Dictionary):
	var location_object:Location = Location.new(location_data)
	emit_signal("location_update", location_object)
	
func _on_heading_update(heading_data:Dictionary):
	emit_signal("heading_update", heading_data)

func _on_location_capability_result(capable:bool):
	emit_signal("location_capability_result",capable)
	_on_log("Test location_capability_result " + str(capable))
	
	
# convenience methods
func request_location_autopermission() -> LocationRequest:
	return LocationRequest.new(self)

func start_updating_location_autopermission() -> LocationWatcher:
	return LocationWatcher.new(self)

func get_and_clear_last_error() ->int:
	var last_error_temp = _last_error
	_last_error = 0
	return last_error_temp
