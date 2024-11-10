extends Node


var session_users: Dictionary = {} # Session user online
var cookie_users: Array = []# List cookie users

var data_users: Dictionary = {} # User account infomation
var users_id: Array = [] # List ID users

var data_players = {}
var players_id: Array = [] 

enum AuthState {
	DANGKI_FAILED = 0,
	DANGKI_OK = 1,
	DANGNHAP_FAILED = 2,
	DANGNHAP_OK = 3,
}

func get_sessions(): return session_users

func update_session_user(id_client: int, account: Dictionary):
	session_users[id_client] = account

#----PLayers Functions-----

func get_info_from_players(uid):
	for player in data_players.keys():
		if data_players[player].has("id_account"):
			var id_account = data_players[player]["id_account"]
			if str(id_account) == str(uid):
				return data_players[player]
		return null
	return null

func update_data_player(new_data: Dictionary):
	var key = new_data.get("id")
	if not data_players.has(key):
		data_players[key] = {}
	for item_key in new_data.keys():
		if item_key != "table":
			data_players[key][item_key] = new_data[item_key]

#----Users Functions-----

func check_login(account: Dictionary):
	for user in data_users.keys():
		if data_users[user].get("taikhoan") == account.get("taikhoan"): 
			if data_users[user].get("matkhau") == account.get("matkhau"):
				return true
	return false

func check_spawnLogin(name_account: String):
	for user in session_users.values():
		if user == name_account:
			return false
	return true

func is_account_valid(user_account: Dictionary):
	var taikhoan = user_account.get("taikhoan")
	for user in data_users:
		if user.get("taikhoan") == taikhoan:
			return true # account available
	return false

func update_data_user(uid, user_account: Dictionary):
	data_users[uid] = user_account
	users_id.append(uid)

func find_uid_from_accounts(user_account: Dictionary):
	for uid in data_users.values():
		if uid == user_account:
			return uid
	return null

func check_exists_uid(uid: String) -> bool:
	return users_id.has(uid)

func generate_random_uid(len_uid: int = 8) -> String:
	var new_uid = ""
	for _i in range(len_uid):
		new_uid += str(randi() % 10)
	return new_uid

func create_uid(len_uid: int = 8) -> String:
	var new_uid = generate_random_uid(len_uid)
	while check_exists_uid(new_uid):
		new_uid = generate_random_uid(len_uid)
	users_id.append(new_uid)
	return new_uid

func remove_uid(uid: String):
	if check_exists_uid(uid):
		users_id.erase(uid)

#------Cookie Users-----

func generate_random_cookie(length: int = 16) -> String:
	var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	var new_cookie = ""
	for _i in range(length):
		new_cookie += chars[rand_range(0, chars.length() - 1)]
	cookie_users.append(new_cookie)
	return new_cookie

func update_cookie_user(uid, cookie):
	var form = {
		"id" : uid,
		"cookie" : cookie
	}
	cookie_users.append(form)

func remove_cookie_user(uid):
	for key_ck in cookie_users:
		if key_ck.get("id") == uid:
			cookie_users.erase(key_ck)



