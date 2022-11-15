# Geolocation Plugin GDScript API Wrapper

GDScript Wrapper Class for easier usage of the Godot Geolocation Plugin for Android () and iOS ()

The GDScript wrapper is incomplete and does not support the heading functionality.

## Install Wrapper

1. Copy `GeolocationWrapper.gd`, `Location.gd`, `LocationRequest.gd` and `LocationWatcher.gd` to your project
2. Add `GeolocationWrapper.gd` to Project > AutoLoad as "GeolocationWrapper"

## Initialization

In your Class define a field for the Wrapper:

```gdscript
var geolocation_api:GeolocationWrapper
```

In the `_ready` method:

```gdscript
geolocation_api= get_node("/root/GeolocationWrapper"

if geolocation_api.supported:
    geolocation_api.connect("authorization_changed", self, "_on_authorization_changed")
    geolocation_api.connect("error", self, "_on_error")
    geolocation_api.connect("debug", self, "_on_debug")
    geolocation_api.connect("location_update", self, "_on_location_update")
    geolocation_api.connect("heading_update", self, "_on_heading_update")

    geolocation_api.set_failure_timeout(30) #optional
    geolocation_api.set_debug_log_signal(true) #optional
```

## API

### Methods

Most plugin API methods (see Geolocation Plugin Readme) are supported.
Locations will be returned as a Location-Class Object with some additional methods (e.g. distance_to_meters(otherLocation:Location))

#### Convenience Methods

The easiest way to use the Geolocation plugin is to use the convenience methods the GDScript wrapper provides:

##### Request current Location

```gdscript
# called when "Request Location" button is pressed
func _on_button_request_location():
    var request = geolocation_api.request_location_autopermission()
    var location:Location = yield(request,"location_update")

    # location is null when no location could be found (no permission, no connection, no capabilty)
    if location == null:
        # log error if an error was reported
        if request.error > 0:
            pass
            # handle error...
            #set_location_output("Error: " + str(request.error))
        return
    # show location 
    location_data_output.text = location.to_string()
```

##### Watch Location

```gdscript
# start updating location button pressed
func _on_button_start_location_updates():
    # stop old watcher
    if location_watcher != null && location_watcher.is_updating:
        location_watcher.stop()
        
    # create watcher and wait for ready
    location_watcher = geolocation_api.start_updating_location_autopermission()
    var success:bool = yield(location_watcher, "ready")
        
    # report error
    if !success:
        # log error if an error was reported
        if location_watcher.error > 0:
            set_location_output("Error: " + str(location_watcher.error))
        return
        
    # wait for new location in loop until stopped
    while(location_watcher.is_updating):
        var location:Location = yield(location_watcher, "location_update")
        if location == null:
            set_location_output("Error: location null where it should never be null")
            continue
        location_data_output.text = location.to_string()

    glog("after watching while loop. should be end here after stop or error")
```

To stop location updates by calling from somwhere else (you need a reference to `locationUpdater`):

```gdscript
# stop updating location button pressed
func _on_button_stop_location_updates():
    if location_watcher != null:
        location_watcher.stop()
```

## License

Copyright 2022 Andreas Ritter (www.wolfbeargames.de)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
