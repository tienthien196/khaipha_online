extends Node

var network = null
var client_online = []
var is_connecting = false # Stating server

const MAX_PLAYERS = 32
const PORT = 7777


func setup_server(port: int , max_client: int):
	network = NetworkedMultiplayerENet.new()
	network.create_server(port, max_client)
	get_tree().set_network_peer(network)
	is_connecting = true
	
func connect_network(do_connect: bool):
	if do_connect:
		get_tree().connect("network_peer_connected", self, "_client_connected")
		get_tree().connect("network_peer_disconnected", self, "_client_disconnected")
	else:
		get_tree().disconnect("network_peer_connected", self, "_client_connected")
		get_tree().disconnect("network_peer_disconnected", self, "_client_disconnected")

func _client_connected(id_client):
	client_online.append(id_client)
	print("Client new connect ID: %d ." % id_client)

func _client_disconnected(id_client):	
	client_online.erase(id_client)
	print("Client disconnect with ID: %d ." % id_client)

func disconnect_network():
	if is_connecting:
		connect_network(false)
		get_tree().network_peer = null
		is_connecting = false

func get_count_client_online():
	var count = len(client_online)
	return count

func boardcast_client_onine():
		rpc("send_client_online", client_online)


