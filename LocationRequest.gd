extends Reference

class_name LocationRequest

#signal ready(success)
signal location_update(location_data)

var geolocation_api #:GeolocationWrapper #don't add type, or we will gat a cyclic dependency error

var is_resolved:bool = false
var error:int = 0

func _init(geo_api):
	geolocation_api = geo_api
	geolocation_api._on_log("** Starting new Request **")
	_request()
	
func _request():
	_listen_for_error()
	
	var status = geolocation_api.authorization_status()
	if  status != geolocation_api.geolocation_authorization_status.PERMISSION_STATUS_ALLOWED:
		geolocation_api._on_log("** request permission")
		geolocation_api.request_permissions()
		var new_status = yield(geolocation_api, "authorization_changed")
		if new_status != geolocation_api.geolocation_authorization_status.PERMISSION_STATUS_ALLOWED:
			error = geolocation_api.geolocation_error_codes.ERROR_DENIED
			is_resolved = true
			emit_signal("location_update",null)
			return
		
	if geolocation_api.should_check_location_capability():
		geolocation_api.request_location_capabilty()
		var capable = yield(geolocation_api, "location_capability_result")
		if !capable:
			error = geolocation_api.geolocation_error_codes.ERROR_LOCATION_DISABLED
			is_resolved = true
			emit_signal("location_update",null)
			return
		
	
	geolocation_api._on_log("** try request location")
	# request even if authorization_changed status is denied, because we want an error to happen
	_listen_for_location()
	geolocation_api.request_location()
	
func _on_location_update(location:Location):
	emit_signal("location_update",location)
	
func _listen_for_error():
	error = yield(geolocation_api, "error")
	geolocation_api._on_log("** error happend")
	if is_resolved:
		return # request already resolved error irrelevant
	
	is_resolved = true
	geolocation_api._on_log("** emit null location to yield")
	emit_signal("location_update", null) # no location, so send null
	
func _listen_for_location():
	var location = yield(geolocation_api, "location_update")
	geolocation_api._on_log("** location received")
	if is_resolved:
		return # request already resolved with error
	
	is_resolved = true	
	emit_signal("location_update", location) # send location, so send null
