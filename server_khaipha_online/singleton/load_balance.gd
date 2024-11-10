extends Node


var get_data = HTTPRequest.new()
var post_data = HTTPRequest.new()
var put_data = HTTPRequest.new()
var delete_data = HTTPRequest.new()

var is_get_requesting: bool = false
var is_post_requesting: bool = false
var is_put_requesting: bool = false
var is_delete_requesting: bool = false

const API_URL = "http://localhost/api.php"

signal get_data_completed(result, response_code, body)
signal post_data_completed(result, response_code, body)
signal put_data_completed(result, response_code, body)
signal delete_data_completed(result, response_code, body)

#list table load khi run game
var load_tables = [
	"player_info"
]

func _ready():
	add_child(get_data)
	add_child(post_data)
	add_child(put_data)
	add_child(delete_data)
	
	get_data.connect("request_completed", self, "_on_get_data")
	post_data.connect("request_completed", self, "_on_post_data")
	put_data.connect("request_completed", self, "_on_put_data")
	delete_data.connect("request_completed", self, "_on_delete_data")

func enqueue_request(table: String):
	load_tables.append(table)

func get_nameTable(data_response) -> String:
	var new_data = parse_json(data_response).get("meta").get("table_name")
	return new_data

func _on_get_data(result, response_code, _headers, body):
	is_get_requesting = false
	var data = body.get_string_from_utf8()
	if response_code == 200:
		emit_signal("get_data_completed", result, response_code, data)
		if load_tables.size() > 0:
			var table = load_tables.pop_front()
			get_data(table) 
		return
	print("Error request status: ", response_code)
	print("ERROR CONNECT DATABASE !!!")
	print("==========================")

func _on_post_data(result, response_code, headers, body):
	is_post_requesting = false
	var data = body.get_string_from_utf8()
	if response_code == 200:
		emit_signal("post_data_completed", result, response_code, data)
		return
	print("Error send method post data: ", data)

func _on_put_data(result, response_code, headers, body):
	is_put_requesting = false
	var data = body.get_string_from_utf8()
	if response_code == 200:
		emit_signal("put_data_completed", result, response_code, data)
		return
	print("Error send method put data: ", data)

func _on_delete_data(result, response_code, headers, body):
	is_delete_requesting = false
	var data = body.get_string_from_utf8()
	if response_code == 200:
		emit_signal("delete_data_completed", result, response_code, data)
		return
	print("Error send method put data: ", data)


#----API Database--------

func get_data(table: String):
	if is_get_requesting:
		return

	is_get_requesting = true
	var url = API_URL + "?table=" + table
	var err = get_data.request(url)
	if err != OK:
		print("Error sending GET request: ", err)
		is_get_requesting = false

func post_data(table: String, data: Dictionary):
	if is_post_requesting:
		return

	is_post_requesting = true
	var form = ""
	for key in data.keys():
		if key is Array:
			for itemkey in key:
				form += "&%s[]=%s" % [key, key[itemkey].percent_encode()]
		else:
			form += "&" + key + "=" + str(data[key]).percent_encode()

	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var err = post_data.request(API_URL, headers, true, HTTPClient.METHOD_POST, form)
	if err != OK:
		print("Error sending POST request: ", err)
		is_post_requesting = false

func put_data(table: String, data: Dictionary):
	if is_put_requesting:
		return

	is_put_requesting = true
	var form_data = ""
	for key in data.keys():
		form_data += key + "=" + str(data[key]).percent_encode()
	form_data = form_data.strip_edges("&")  

	var url = API_URL + "?table=" + table 
	var err = put_data.request(url, [], true, HTTPClient.METHOD_PUT, form_data)  
	if err != OK:
		print("Error sending PUT request: ", err)
		is_put_requesting = false

func delete_data(table: String, data: Dictionary):
	if is_delete_requesting:
		return

	is_delete_requesting = true
	var form_data = ""
	for key in data.keys():
		form_data += key + "=" + str(data[key]).percent_encode()
	form_data = form_data.strip_edges("&") 

	var url = API_URL + "?table=" + table 
	var err = delete_data.request(url, [], true, HTTPClient.METHOD_DELETE, form_data)  
	if err != OK:
		print("Error sending DELETE request: ", err)
		is_delete_requesting = false

