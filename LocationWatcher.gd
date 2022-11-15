extends Reference

class_name LocationWatcher

signal ready(success)
signal location_update(location_data)

var geolocation_api # :GeolocationWrapper #don't add type, or we will gat a cyclic dependency error

var is_updating:bool = false
var error = 0

func _init(geo_api):
	geolocation_api = geo_api
	_make_ready()
	
func _make_ready():
	# request one location and authorize before when neccessary
	var request = geolocation_api.request_location_autopermission()
	var location:Location = yield(request,"location_update")
	
	# location is null when no location could be found (no permission, no connection)
	if location == null:
		error = request.error
		emit_signal("ready",false)
		return
		
	# have location
	is_updating = true
	emit_signal("ready",true)
	
	_listen_for_error()
		
	geolocation_api.start_updating_location()
	geolocation_api.connect("location_update",self,"_on_location_update")
	emit_signal("location_update",location)
	
func _on_location_update(location:Location):
	emit_signal("location_update",location)
	
func _listen_for_error():
	error = yield(geolocation_api, "error")
	geolocation_api._on_log("** error happend in watcher")
	# stop watcher on error
	stop()
	
func stop():
	geolocation_api.disconnect("location_update",self,"_on_location_update")
	geolocation_api.stop_updating_location()
	is_updating = false
	emit_signal("location_update", null) # no location, so send null
