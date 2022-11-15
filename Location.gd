extends Object

class_name Location

var latitude:float 
var longitude:float 
var accuracy:float
var altitude:float
var altitude_accuracy:float
var course:float
var course_accuracy:float
var speed:float
var speed_accuracy:float
var timestamp:int

var lat_string:String
var lon_string:String


func _init(location_data:Dictionary):
	latitude = float(location_data["latitude_string"])
	longitude = float(location_data["longitude_string"])
	
	#latitude = location_data["latitude"]
	#longitude = location_data["longitude"]
	
	accuracy = location_data["accuracy"]
	altitude = location_data["altitude"]
	altitude_accuracy = location_data["altitude_accuracy"]
	
	course = location_data["course"]
	course_accuracy = location_data["course_accuracy"]
	
	speed = location_data["speed"]
	speed_accuracy = location_data["speed_accuracy"]
	
	timestamp = location_data["timestamp"]
	
	lat_string = location_data["latitude_string"] 
	lon_string = location_data["longitude_string"]
	
func get_speed_kph()->float:
	return speed *3.6
	
func get_speed_mph()->float:
	return speed *2.237	

func distance_to_kilometers(other_location:Location) -> float:
	return _calculate_distance(latitude,longitude,other_location.latitude,other_location.longitude)

func distance_to_meters(other_location:Location) -> float:
	return distance_to_kilometers(other_location)*1000

func _calculate_distance(lat1:float, long1:float, lat2:float, long2:float) -> float:
	var d2r = (PI / 180.0)
	var dlong:float = (long2 - long1) * d2r
	var dlat:float = (lat2 - lat1) * d2r
	var a:float = pow(sin(dlat / 2.0), 2) + cos(lat1 * d2r) * cos(lat2 * d2r) * pow(sin(dlong / 2.0), 2)
	var c:float = 2 * atan2(sqrt(a),sqrt(1 - a))
	var d:float = 6367 * c
	return d;
	
func _to_string():
	var props = []
	props.append("Location Object")
	props.append("latitude : %f" % [latitude])
	props.append("longitude : %f" % [longitude])
	props.append("accuracy : %f" % [accuracy])
	props.append("altitude : %f" % [altitude])
	props.append("altitude_accuracy : %f" % [altitude_accuracy])
	props.append("course : %f" % [course])
	props.append("course accuracy : %f" % [course_accuracy])
	props.append("speed : %f" % [speed])
	props.append("speed_accuracy : %f" % [speed_accuracy])
	props.append("timestamp : %d" % [timestamp])
	props.append("latitude_string : %s" % [lat_string])
	props.append("longitude_string : %s" % [lon_string])
	return PoolStringArray(props).join("\n")
