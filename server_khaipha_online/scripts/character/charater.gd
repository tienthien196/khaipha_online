extends KinematicBody2D

class_name CharacterManager

# --- Thuoc tinh co ban ---
var type_character = null
var targets: Array = []
var inventory: Array = []
var buffs: Dictionary = {}
var status: String = "alive"
var health: int
var mana: int
var max_health = 100
var max_mana = 100
var defense: int
var damage_attack: int
var speed: int

# --- Trang thai va thong tin di chuyen ---
var is_moving = false
var is_attacking = false
var is_defending = false
var is_hidden = false
var target_position = Vector2()
var patrol_path = []
var current_patrol_index = 0

const MAX_POWER = 1000

enum CharacterType {
	PLAYER,
	ENEMY
}

# --- 1. Tan cong muc tieu ---
func attack_target(target: CharacterManager):
	if targets.has(target) and target.status == "alive":
		var damage = damage_attack - target.defense
		damage = max(damage, 1)
		target.take_damage(damage)
		print("%s attacks %s for %d damage!" % [self.name, target.name, damage])
		return damage
	return 0

# --- 2. Hoi diem cho suc khoe hoac mana ---
func restore_points(amount: int, attribute: String):
	if attribute == "health":
		health = min(health + amount, max_health)
	elif attribute == "mana":
		mana = min(mana + amount, max_mana)
	return true

# --- 3. Kiem tra trang thai song ---
func is_alive():
	return status == "alive"

# --- 4. Di chuyen toi vi tri ---
func move_to_position(position: Vector2):
	if is_alive():
		target_position = position
		is_moving = true

# --- 5. Di chuyen tuan tra ---
func start_patrol():
	if patrol_path.size() > 0:
		current_patrol_index = 0
		move_to_position(patrol_path[current_patrol_index])

# --- 6. Cap nhat vi tri khi di chuyen ---
func _process(delta):
	if is_moving and is_alive():
		var direction = (target_position - global_position).normalized()
		move_and_slide(direction * speed)
		if global_position.distance_to(target_position) < 10:
			is_moving = false
			on_reach_position()

# --- 7. Xu ly khi dat den vi tri tuan tra ---
func on_reach_position():
	if patrol_path.size() > 0:
		current_patrol_index = (current_patrol_index + 1) % patrol_path.size()
		move_to_position(patrol_path[current_patrol_index])

# --- 8. Nhan sat thuong ---
func take_damage(damage: int):
	if is_alive():
		var effective_damage = max(damage - defense, 0)
		health -= effective_damage
		print("%s takes %d damage!" % [name, effective_damage])
		if health <= 0:
			die()

# --- 9. Hoi mau ---
func heal(amount: int):
	health = min(health + amount, max_health)
	print("%s heals for %d health!" % [name, amount])

# --- 10. Hoi KI (mana/energy) ---
func restore_ki(amount: int):
	mana = min(mana + amount, max_mana)
	print("%s restores %d mana!" % [name, amount])

# --- 11. Kiem tra trang thai song ---
func is_alive_status() -> bool:
	return status == "alive"

# --- 12. Chet ---
func die():
	status = "dead"
	print("%s has died." % name)
	queue_free()

# --- 13. Hoi sinh ---
func revive():
	status = "alive"
	health = max_health
	mana = max_mana
	print("%s has revived!" % name)

# --- 14. Kiem tra khoang cach den nguoi choi ---
func distance_to_player(player) -> float:
	return global_position.distance_to(player.global_position)

# --- 15. Tron thoat khi bi tan cong ---
func flee_from(player):
	if is_alive():
		var flee_direction = (global_position - player.global_position).normalized()
		target_position = global_position + flee_direction * 200
		is_moving = true
		print("%s is fleeing!" % name)

# --- 16. Che do phong thu ---
func defend():
	is_defending = true
	defense *= 2
	print("%s is defending!" % name)

# --- 17. Ket thuc phong thu ---
func stop_defending():
	is_defending = false
	defense /= 2
	print("%s stops defending!" % name)

# --- 18. Tuong tac voi vat pham ---
func interact_with_item(item):
	print("%s interacts with %s." % [name, item.name])
	if item.type == "healing":
		heal(item.value)
	elif item.type == "energy":
		restore_ki(item.value)

# --- 19. Ky nang dac biet ---
func special_attack(target: CharacterManager):
	if mana >= 20:
		mana -= 20
		var special_damage = damage_attack * 1.5
		target.take_damage(special_damage)
		print("%s performs a special attack for %d damage!" % [name, special_damage])

# --- 20. Kiem tra chi so ---
func check_status():
	print("%s - Health: %d/%d | Mana: %d/%d" % [name, health, max_health, mana, max_mana])

# --- 21. Phuc hoi tat ca trang thai ---
func reset_status():
	health = max_health
	mana = max_mana
	status = "alive"
	is_moving = false
	is_attacking = false
	is_defending = false
	print("%s's status has been reset." % name)

# --- 22. Kiem tra vi tri co the tan cong ---
func can_attack_position(position: Vector2) -> bool:
	return global_position.distance_to(position) <= 50

# --- 23. Che do an nap ---
func hide():
	is_hidden = true
	print("%s is hiding!" % name)

# --- 24. Phat hien nguoi choi ---
func detect_player(player):
	if distance_to_player(player) < 200:
		print("%s has detected the player!" % name)

# --- 26. Trang thai bi lam cham ---
func apply_slow_effect(duration: float, speed_reduction: float):
	speed -= speed_reduction
	yield(get_tree().create_timer(duration), "timeout")
	speed += speed_reduction
	print("%s is slowed!" % name)

# --- 27. Phong lao ---
func throw_projectile(target: CharacterManager):
	if is_alive():
		print("%s throws a projectile at %s!" % [name, target.name])

# --- 28. Goi dong minh ho tro ---
func call_for_backup():
	print("%s calls for backup!" % name)

# --- 29. Ap dung hieu ung tang suc manh ---
func apply_buff(buff_name: String, value: int):
	buffs[buff_name] = value
	print("%s gains a %s buff of %d!" % [name, buff_name, value])

# --- 30. Loai bo hieu ung buff ---
func remove_buff(buff_name: String):
	if buffs.has(buff_name):
		buffs.erase(buff_name)
		print("%s's %s buff has been removed!" % [name, buff_name])

# --- 31. Tang toc do di chuyen ---
func apply_speed_boost(duration: float, speed_increase: float):
	speed += speed_increase
	yield(get_tree().create_timer(duration), "timeout")
	speed -= speed_increase
	print("%s gains a speed boost!" % name)

# --- 32. Tang kha nang phong thu ---
func apply_defense_boost(duration: float, defense_increase: int):
	defense += defense_increase
	yield(get_tree().create_timer(duration), "timeout")
	defense -= defense_increase
	print("%s gains a defense boost!" % name)

# --- 33. Lam cham muc tieu ---
func apply_freeze_effect(target: CharacterManager, duration: float):
	if target.is_alive():
		var original_speed = target.speed
		target.speed = max(0, target.speed - 50)
		yield(get_tree().create_timer(duration), "timeout")
		target.speed = original_speed
		print("%s froze %s!" % [name, target.name])

# --- 34. Ky nang ap dung buff cho ban than hoac dong doi ---
func apply_buff_to_team(buff_name: String, value: int, target: CharacterManager = null):
	if target == null:
		apply_buff(buff_name, value)
		print("%s applies a %s buff to themselves!" % [name, buff_name])
	else:
		target.apply_buff(buff_name, value)
		print("%s applies a %s buff to %s!" % [name, buff_name, target.name])

# --- 35. Dung vat pham tu kho ---
func use_item_from_inventory(item_index: int):
	if item_index < inventory.size():
		var item = inventory[item_index]
		print("%s uses item: %s" % [name, item.name])
		interact_with_item(item)
		inventory.remove(item_index)
	else:
		print("Invalid item index.")

# --- 36. Combo Attack ---
func perform_combo_attack(target: CharacterManager):
	if mana >= 50:
		mana -= 50
		var combo_damage = (damage_attack * 2) - target.defense
		combo_damage = max(combo_damage, 1)
		target.take_damage(combo_damage)
		print("%s performs a combo attack for %d damage!" % [name, combo_damage])
	else:
		print("%s doesn't have enough mana for a combo!" % name)

# --- 37. AI hanh dong tu dong ---
func ai_behavior(player: CharacterManager):
	if distance_to_player(player) < 100:
		attack_target(player)
	elif distance_to_player(player) < 300:
		flee_from(player)
	else:
		if !is_moving:
			var random_position = Vector2(rand_range(-200, 200), rand_range(-200, 200)) + global_position
			move_to_position(random_position)

# --- 38. Hoi phục toàn bộ ---
func heal_all(amount: int):
	health = min(health + amount, max_health)
	print("%s heals themselves for %d health!" % [name, amount])

func heal_all_team(amount: int, team_members: Array):
	for member in team_members:
		if member.is_alive():
			member.heal(amount)
		print("%s heals %s for %d health!" % [name, member.name, amount])

# --- 39. Kiếm kinh nghiệm (XP) ---
var experience: int = 0
var level: int = 1

func gain_experience(amount: int):
	experience += amount
	print("%s gains %d XP!" % [name, amount])
	check_level_up()

func check_level_up():
	if experience >= level * 100:
		level += 1
		experience = 0
		print("%s leveled up! New level: %d" % [name, level])

# --- 40. Kẻ thù có đặc điểm khác nhau ---
enum EnemyType {
	NORMAL,
	BOSS,
	ELITE
}

var enemy_type = EnemyType.NORMAL
var boss_health = 200
var boss_damage = 30

func set_boss_status():
	enemy_type = EnemyType.BOSS
	max_health = boss_health
	damage_attack = boss_damage
	print("%s is now a boss with %d health and %d damage!" % [name, boss_health, boss_damage])
