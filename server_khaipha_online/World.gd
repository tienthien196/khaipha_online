extends Node


func _ready():
	Networking.setup_server(Networking.PORT, Networking.MAX_PLAYERS)
	LoadBalance.get_data("acc_count")

