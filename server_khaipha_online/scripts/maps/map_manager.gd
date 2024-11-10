extends Node

class_name MapService

# Thuộc tính của bản đồ
var map_name: String
var description: String
var zones: Array = []  # Mảng chứa các khu vực trong bản đồ
var npcs: Array = []  # Mảng chứa NPCs trong bản đồ
var enemies: Array = []  # Mảng chứa kẻ thù trong bản đồ
var items: Array = []  # Mảng chứa vật phẩm trong bản đồ

# Dữ liệu phòng cho mỗi cấp độ
var current_rooms = {}  # Lưu trữ rooms theo từng level
var info_rooms = {}     # Dữ liệu phòng theo từng level
var player_position = {} # Lưu vị trí người chơi trong các phòng

# Dữ liệu bản đồ mẫu cho nhiều cấp độ
var map_data = {
	1: [
		{"id": 1, "players": [], "items": ["sword"], "enemies": ["goblin"], "state": "waiting", "type": "forest"},
		{"id": 2, "players": [], "items": ["shield"], "enemies": ["orc"], "state": "waiting", "type": "forest"}
	],
	2: [
		{"id": 3, "players": [], "items": ["magic_wand"], "enemies": ["dragon"], "state": "waiting", "type": "dungeon"},
		{"id": 4, "players": [], "items": ["key"], "enemies": ["troll"], "state": "waiting", "type": "dungeon"}
	]
}

func _ready():
	# Khi MapService khởi động, tiến hành thiết lập bản đồ
	setup_map(1)  # Ví dụ: thiết lập cấp độ 1

# Các phương thức để thêm khu vực, NPC, kẻ thù, vật phẩm
func add_zone(zone):
	zones.append(zone)

func add_npc(npc):
	npcs.append(npc)

func add_enemy(enemy):
	enemies.append(enemy)

func add_item(item):
	items.append(item)

func show_info():
	print("Map: %s" % map_name)
	print("Description: %s" % description)
	print("Zones: %d" % zones.size())
	print("NPCs: %d" % npcs.size())
	print("Enemies: %d" % enemies.size())
	print("Items: %d" % items.size())

# Thiết lập bản đồ cho một cấp độ
func setup_map(level: int):
	if map_data.has(level):
		current_rooms[level] = []
		info_rooms[level] = []
		for room_data in map_data[level]:
			var room = create_room(room_data)
			current_rooms[level].append(room)
			info_rooms[level].append(room_data)
		print("Map setup complete for level %d with %d rooms." % [level, current_rooms[level].size()])
	else:
		print("Level %d does not exist." % level)

# Tạo một phòng từ dữ liệu được cung cấp
func create_room(data):
	var room = {}
	room["id"] = data.get("id", 0)
	room["players"] = data.get("players", [])
	room["items"] = data.get("items", [])
	room["enemies"] = data.get("enemies", [])
	room["state"] = data.get("state", "waiting")  # Trạng thái phòng: waiting, active, completed
	room["type"] = data.get("type", "unknown")    # Loại phòng: forest, dungeon, v.v.
	return room

# Lấy thông tin của bản đồ cho một cấp độ
func dump_map(level: int):
	if info_rooms.has(level):
		var map_info = []
		for room in info_rooms[level]:
			map_info.append(room)
		return map_info
	else:
		print("Level %d not found." % level)
		return []

# Thêm người chơi vào một phòng của cấp độ cụ thể
func join_map(player, room_id, level: int):
	if current_rooms.has(level):
		for room in current_rooms[level]:
			if room["id"] == room_id:
				room["players"].append(player)
				player_position[player] = room_id  # Cập nhật vị trí người chơi
				print("Player %s joined room %d in level %d." % [player, room_id, level])
				return true
		print("Room ID %d not found in level %d." % [room_id, level])
		return false
	print("Level %d not found." % level)
	return false

# Thêm kẻ thù vào phòng trong cấp độ cụ thể
func add_enemy_to_room(enemy, room_id, level: int):
	if current_rooms.has(level):
		for room in current_rooms[level]:
			if room["id"] == room_id:
				room["enemies"].append(enemy)
				print("Enemy %s added to room %d in level %d." % [enemy, room_id, level])
				return true
	print("Room ID %d not found in level %d." % [room_id, level])
	return false

# Xóa kẻ thù khỏi phòng trong cấp độ cụ thể
func remove_enemy_from_room(enemy, room_id, level: int):
	if current_rooms.has(level):
		for room in current_rooms[level]:
			if room["id"] == room_id and enemy in room["enemies"]:
				room["enemies"].erase(enemy)
				print("Enemy %s removed from room %d in level %d." % [enemy, room_id, level])
				return true
	print("Room ID %d not found in level %d." % [room_id, level])
	return false

# Di chuyển người chơi giữa các phòng trong cấp độ cụ thể
func move_player(player, new_room_id, level: int):
	if player_position.has(player):
		var old_room_id = player_position[player]
		# Xóa người chơi khỏi phòng cũ
		for room in current_rooms[level]:
			if room["id"] == old_room_id:
				room["players"].erase(player)
		# Thêm người chơi vào phòng mới
		for room in current_rooms[level]:
			if room["id"] == new_room_id:
				room["players"].append(player)
				player_position[player] = new_room_id
				print("Player %s moved to room %d in level %d." % [player, new_room_id, level])
				return true
	print("Player %s cannot move to room %d in level %d." % [player, new_room_id, level])
	return false

# Thu thập vật phẩm từ phòng trong cấp độ cụ thể
func collect_item(player, item, room_id, level: int):
	if current_rooms.has(level):
		for room in current_rooms[level]:
			if room["id"] == room_id and item in room["items"]:
				room["items"].erase(item)
				print("Player %s collected item %s in room %d of level %d." % [player, item, room_id, level])
				return true
	print("Item %s not found in room %d of level %d." % [item, room_id, level])
	return false

# Lấy số lượng người chơi trong phòng của cấp độ cụ thể
func get_player_count(room_id, level: int):
	if current_rooms.has(level):
		for room in current_rooms[level]:
			if room["id"] == room_id:
				return room["players"].size()
	return 0

# Lấy danh sách kẻ thù trong phòng của cấp độ cụ thể
func get_enemies(room_id, level: int):
	if current_rooms.has(level):
		for room in current_rooms[level]:
			if room["id"] == room_id:
				return room["enemies"]
	return []

# Lấy danh sách vật phẩm trong phòng của cấp độ cụ thể
func get_items(room_id, level: int):
	if current_rooms.has(level):
		for room in current_rooms[level]:
			if room["id"] == room_id:
				return room["items"]
	return []
