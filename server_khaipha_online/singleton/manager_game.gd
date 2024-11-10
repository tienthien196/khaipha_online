extends Node

# Quan ly cac ban do va nhiem vu trong game
class_name MapManager

# Luu tru tat ca cac ban do trong game
var maps: Dictionary = {}
var current_map: MapService = null  # Ban do hien tai

# Luu tru cac nhiem vu trong game
var tasks: Dictionary = {}

# Phuong thuc de them ban do moi vao quan ly
func add_map(map_obj: MapService):
	if map_obj and not maps.has(map_obj.map_name):
		maps[map_obj.map_name] = map_obj
		print("Added map: %s" % map_obj.map_name)
	else:
		print("Map %s already exists or invalid map!" % map_obj.map_name)

# Phuong thuc de chuyen sang ban do khac
func change_map(map_name: String):
	if map_name in maps:
		if current_map:
			current_map.queue_free()  # Giai phong ban do hien tai khoi scene
		current_map = maps[map_name]
		get_tree().current_scene.add_child(current_map)  # Them ban do moi vao scene
		print("Changed to map: %s" % map_name)
		# Kiem tra nhiem vu lien quan den ban do khi thay doi
		check_tasks_for_current_map(map_name)
	else:
		print("Map %s not found!" % map_name)

# Phuong thuc de hien thi thong tin cua ban do hien tai
func show_current_map_info():
	if current_map:
		current_map.show_info()
	else:
		print("No current map.")

# Phuong thuc de xoa ban do khoi quan ly
func remove_map(map_name: String):
	if map_name in maps:
		maps[map_name].queue_free()  # Giai phong ban do khoi scene
		maps.erase(map_name)
		print("Removed map: %s" % map_name)
	else:
		print("Map %s not found to remove!" % map_name)

# Phuong thuc de lay ban do theo ten
func get_map(map_name: String) -> MapService:
	if map_name in maps:
		return maps[map_name]
	else:
		print("Map %s not found!" % map_name)
		return null

# Phuong thuc de kiem tra xem ban do da duoc them vao chua
func has_map(map_name: String) -> bool:
	return maps.has(map_name)

# Phuong thuc de them nhiem vu moi
func add_task(task_name: String, task_obj):
	if not tasks.has(task_name):
		tasks[task_name] = task_obj
		print("Added task: %s" % task_name)
	else:
		print("Task %s already exists!" % task_name)

# Phuong thuc de lay nhiem vu theo ten
func get_task(task_name: String):
	if tasks.has(task_name):
		return tasks[task_name]
	else:
		print("Task %s not found!" % task_name)
		return null

# Phuong thuc de xoa nhiem vu khoi quan ly
func remove_task(task_name: String):
	if tasks.has(task_name):
		tasks.erase(task_name)
		print("Removed task: %s" % task_name)
	else:
		print("Task %s not found to remove!" % task_name)

# Phuong thuc de kiem tra nhiem vu lien quan den ban do hien tai
func check_tasks_for_current_map(map_name: String):
	for task_name in tasks.keys():
		var task = tasks[task_name]
		# Kiem tra xem nhiem vu co phu hop voi ban do hien tai hay khong
		if task.is_related_to_map(map_name):
			print("Task %s is related to current map: %s" % [task_name, map_name])
			task.update_task_status()  # Cap nhat trang thai nhiem vu
		else:
			print("Task %s is not related to current map: %s" % [task_name, map_name])


