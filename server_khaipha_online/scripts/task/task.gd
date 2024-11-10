extends Node

class_name Task

enum TaskStatus {
	NOT_STARTED,  # Chua bat dau
	IN_PROGRESS,  # Dang thuc hien
	COMPLETED,    # Hoan thanh
	FAILED        # That bai
}

var task_id: int  # ID cua nhiem vu
var title: String  # Ten cua nhiem vu
var description: String  # Mo ta cua nhiem vu
var reward: Reward  # Phan thuong cua nhiem vu
var status: TaskStatus = TaskStatus.NOT_STARTED  # Trang thai cua nhiem vu
var objectives: Array = []  # Danh sach muc tieu cua nhiem vu
var starting_location: Vector3  # Vi tri bat dau nhiem vu
var ending_location: Vector3  # Vi tri ket thuc nhiem vu
var conditions: Array = []  # Danh sach dieu kien cua nhiem vu
var progress: int = 0  # Tien trinh cua nhiem vu
var priority: int  # Do uu tien cua nhiem vu
var category: String  # The loai cua nhiem vu
var time_limit: float = -1  # Gioi han thoi gian (neu co)
var start_time: float = 0  # Thoi gian bat dau nhiem vu
var level_requirement: int = 1  # Yeu cau cap do toi thieu de nhan nhiem vu
var challenges: Array = []  # Danh sach thu thach cua nhiem vu
var side_events: Array = []  # Danh sach su kien phu


# Kiem tra cap do cua nguoi choi co du de nhan nhiem vu khong
func can_accept_task(player_level: int) -> bool:
	return player_level >= level_requirement  # Tra ve true neu cap do nguoi choi du dieu kien

# Bat dau nhiem vu
func start_task():
	status = TaskStatus.IN_PROGRESS  # Dat trang thai nhiem vu la dang thuc hien
	start_time = OS.get_ticks_msec() / 1000  # Luu thoi gian bat dau
	_trigger_side_event("start_task")  # Kich hoat su kien phu khi bat dau nhiem vu

# Hoan thanh nhiem vu
func complete_task():
	status = TaskStatus.COMPLETED  # Dat trang thai nhiem vu la hoan thanh
	reward_player()  # Tra phan thuong cho nguoi choi
	_trigger_side_event("complete_task")  # Kich hoat su kien phu khi hoan thanh nhiem vu

# That bai nhiem vu
func fail_task():
	status = TaskStatus.FAILED  # Dat trang thai nhiem vu la that bai

# Tra phan thuong cho nguoi choi
func reward_player():
	if reward:
		reward.grant()  # Cap phan thuong neu ton tai phan thuong

# Ham kiem tra dieu kien cua nhiem vu
func is_condition_met() -> bool:
	for condition in conditions:  # Duyet qua tung dieu kien
		if not condition.is_met():  # Neu dieu kien khong duoc thoa man
			return false  # Tra ve false
	return true  # Tra ve true neu tat ca dieu kien duoc thoa man

# Ham tang tien trinh cua nhiem vu
func increment_progress(amount: int):
	progress += amount  # Tang tien trinh theo so luong cho truoc

# Ham lay tien trinh cua nhiem vu
func get_progress() -> int:
	return progress  # Tra ve tien trinh hien tai

# Ham dat lai tien trinh
func reset_progress():
	progress = 0  # Dat lai tien trinh ve 0

# Kiem tra nhiem vu co hoan thanh hay khong
func is_complete() -> bool:
	return status == TaskStatus.COMPLETED  # Tra ve true neu nhiem vu da hoan thanh

# Dat do uu tien cho nhiem vu
func set_priority(priority: int):
	self.priority = priority  # Dat do uu tien cho nhiem vu

# Lay do uu tien cua nhiem vu
func get_priority() -> int:
	return priority  # Tra ve do uu tien cua nhiem vu

# Dat the loai cho nhiem vu
func set_category(category: String):
	self.category = category  # Dat the loai cho nhiem vu

# Lay the loai cua nhiem vu
func get_category() -> String:
	return category  # Tra ve the loai cua nhiem vu

# Kich hoat su kien phu
func _trigger_side_event(event_name: String):
	for event in side_events:  # Duyet qua tung su kien phu
		if event.name == event_name:  # Neu ten su kien phu khop
			event.trigger()  # Kich hoat su kien phu

# Kiem tra thoi gian hoan thanh nhiem vu
func check_time_limit():
	if time_limit > 0 and (OS.get_ticks_msec() / 1000 - start_time) > time_limit:
		fail_task()  # Neu vuot qua gioi han thoi gian, thua nhiem vu
