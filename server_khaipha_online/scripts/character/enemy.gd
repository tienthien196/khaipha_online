extends CharacterManager

class_name Enemy

# --- 1. Khoi tao thong so co ban ---
var aggression_level: int = 0  # Muc do hung han
var detection_range: int = 200  # Khoang cach phat hien
var attack_range: int = 50  # Pham vi tan cong
var respawn_time: float = 10.0  # Thoi gian hoi sinh sau khi chet

# --- 2. Phat hien nguoi choi ---
func detect_player(player):
	if self.is_alive and self.global_position.distance_to(player.global_position) <= detection_range:
		print("%s phat hien nguoi choi!" % name)
		engage_player(player)

# --- 3. Tan cong nguoi choi ---
func engage_player(player):
	if self.is_alive and self.global_position.distance_to(player.global_position) <= attack_range:
		pass
		#attack_player(player)
	else:
		pass
		#move_towards_player(player.global_position)

# --- 4. Tu dong di chuyen toi nguoi choi neu bi phat hien ---
func auto_chase_player(player):
	if self.is_alive and self.global_position.distance_to(player.global_position) <= detection_range:
		#move_towards_player(player.global_position)
		print("%s dang truy duoi nguoi choi!" % name)

# --- 5. Di chuyen ve diem xuat phat neu khong phat hien nguoi choi ---
func return_to_spawn():
	if self.is_alive and self.global_position.distance_to(self.spawn_position) > 10:
		move_to_position(self.spawn_position)
		print("%s dang tro lai vi tri xuat phat!" % name)

# --- 6. Ky nang tan cong dat biet ---
func special_attack(player):
	if self.is_alive and aggression_level >= 5:
		aggression_level = 0  # Reset muc do hung han sau tan cong dac biet
		var special_damage = damage_attack * 2
		player.take_damage(special_damage)
		print("%s tan cong dat biet gay %d sat thuong!" % [name, special_damage])

# --- 7. Tu tang muc do hung han khi bi tan cong ---
func increase_aggression():
	if self.is_alive:
		aggression_level += 1
		print("%s muc do hung han tang len %d" % [name, aggression_level])

# --- 8. Tan cong khong nguoi choi ---
func attack_non_player(target):
	if self.is_alive and is_in_attack_range(target):
		target.take_damage(damage_attack)
		print("%s tan cong muc tieu voi %d sat thuong!" % [name, damage_attack])

# --- 9. Xac dinh khong cach ---
func is_in_attack_range(target) -> bool:
	return global_position.distance_to(target.global_position) <= attack_range

# --- 10. Tu dong che do phong thu khi bi tan cong ---
func auto_defend():
	if self.is_alive and aggression_level > 3:
		defend()
		print("%s dang tu dong phong thu!" % name)

# --- 11. Thoat che do phong thu ---
func exit_defense_mode():
	stop_defending()
	print("%s da dung che do phong thu." % name)

# --- 12. Hoi sinh sau khi chet ---
func respawn():
	yield(get_tree().create_timer(respawn_time), "timeout")
	revive()
	print("%s da hoi sinh tai vi tri xuat phat!" % name)

# --- 13. Cap nhat tinh trang khi bi tan cong ---
func update_status_on_damage(damage):
	take_damage(damage)
	if health <= 0:
		die()
	else:
		increase_aggression()

# --- 14. Bo sung pham vi di tuan tra ---
func set_patrol_path(path_points):
	patrol_path = path_points
	start_patrol()
	print("%s bat dau tuan tra." % name)

# --- 15. Kiem tra vi tri cua nguoi choi ---
func is_player_in_sight(player) -> bool:
	return global_position.distance_to(player.global_position) <= detection_range

# --- 16. Tinh trang bao dong ---
func alert_nearby_allies():
	print("%s bao dong cac dong doi gan day!" % name)
	# Logic phat hien ke dich gan day de bao dong dong doi

# --- 17. Tranh khoi nguoi choi neu can thiet ---
func flee_if_needed(player):
	if health < max_health * 0.3:  # Neu suc khoe duoi 30%
		pass
		#flee_from_player(player)

# --- 18. Kiem tra chi so suc khoe va phong thu cua doi thu ---
func assess_enemy_strength(enemy) -> bool:
	return enemy.health < health or enemy.defense < defense

# --- 19. Chuan bi tan cong lan tiep ---
func prepare_for_next_attack():
	aggression_level += 2  # Tang muc do hung han truoc khi tan cong lan tiep theo
	print("%s dang chuan bi tan cong tiep theo!" % name)

# --- 20. Hoi phuc nhe neu khong co doi thu ---
func minor_heal():
	if not is_moving and health < max_health * 0.5:
		heal(10)
		print("%s dang hoi phuc!" % name)

# --- 21. Bao ve khi o gan dong doi ---
func assist_ally(ally):
	if self.is_alive and self.global_position.distance_to(ally.global_position) < detection_range:
		ally.defend()
		print("%s ho tro phong thu cho dong doi %s!" % [name, ally.name])

# --- 22. Tu chon vi tri de mai phuc ---
func choose_ambush_position():
	target_position = global_position + Vector2(randi() % 100 - 50, randi() % 100 - 50)
	move_to_position(target_position)
	print("%s dang chuan bi mai phuc!" % name)

# --- 23. Tham gia chien dau neu co ke dich gan ---
func join_battle_nearby(enemies):
	for enemy in enemies:
		if is_player_in_sight(enemy):
			engage_player(enemy)

# --- 24. Bao ve khu vuc dac biet ---
func guard_area():
	patrol_path = [global_position + Vector2(50, 0), global_position - Vector2(50, 0)]
	start_patrol()
	print("%s dang bao ve khu vuc!" % name)

# --- 25. Hoat dong khac khi bi tan cong ---
func counter_attack(player):
	if self.is_alive and aggression_level > 4:
		special_attack(player)
		print("%s dang phan cong tan cong!" % name)

# --- 26. Tu dong phat hien ke dich gan day ---
func auto_detect_enemies(enemies):
	for enemy in enemies:
		if is_in_attack_range(enemy):
			attack_non_player(enemy)

# --- 27. Dieu khien dong doi tan cong nguoi choi ---
func command_allies_to_attack(player):
	print("%s ra lenh dong doi tan cong!" % name)
	# Logic tuong tac voi dong doi de tan cong

# --- 28. Phan ung voi vat pham tren san ---
func react_to_item(item):
	if is_in_attack_range(item):
		print("%s phat hien vat pham %s!" % [name, item.name])

# --- 29. Cap nhat tinh trang sau moi dot tan cong ---
func update_after_attack():
	if self.is_alive:
		aggression_level = 0  # Reset muc do hung han
		print("%s dang tai tao muc do hung han!" % name)

# --- 30. Kiem tra va doi pho voi tuong ngap ---
func check_obstacle_and_avoid():
	if is_moving:
		var collision = move_and_slide(Vector2(randf() * 10, randf() * 10))
		if collision:
			move_to_position(global_position - collision.position)
			print("%s dang tranh khoi vat can!" % name)
