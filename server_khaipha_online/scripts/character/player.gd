extends CharacterManager

class_name Player

# --- Thuoc tinh va thong so cua Player ---
var max_inventory_size: int = 10  # So luong toi da cua vat pham trong tui
var skill_points: int = 0  # So diem ky nang
var equipped_items: Dictionary = {}  # Danh sach cac vat pham dang trang bi
var gold: int = 0  # So vang cua player
var stamina: int = 100  # So luong suc benh hien tai
var max_stamina: int = 100  # So luong suc benh toi da

# --- 1. Kiem kinh nghiem ---
func gain_experience(amount: int):
	experience += amount  # Tang kinh nghiem cho player
	print("%s gained %d experience!" % [name, amount])  # In ra thong bao
	check_level_up()  # Kiem tra xem player co len cap khong

# --- 2. Kiem tra len cap ---
func check_level_up():
	if experience >= level * 100:  # Neu kinh nghiem vuot qua diem can de len cap
		experience -= level * 100  # Giam kinh nghiem da duoc
		level_up()  # Len cap player

# --- 3. Len cap ---
func level_up():
	level += 1  # Tang cap
	skill_points += 5  # Tang diem ky nang
	health = max_health  # Hoi phuc toan bo mau
	stamina = max_stamina  # Hoi phuc toan bo suc benh
	print("%s leveled up to %d!" % [name, level])  # In ra thong bao player len cap

# --- 4. Su dung diem ky nang ---
func spend_skill_point(attribute: String):
	if skill_points > 0:  # Neu con diem ky nang de su dung
		match attribute:  # Duyet theo thuoc tinh muon tang
			"health":  # Tang so mau toi da
				max_health += 10
			"mana":  # Tang so mana toi da
				max_mana += 10
			"defense":  # Tang chi so phong thu
				defense += 1
			"attack":  # Tang chi so tan cong
				damage_attack += 1
		skill_points -= 1  # Giam 1 diem ky nang
		print("%s spends a skill point on %s!" % [name, attribute])  # In ra thong bao su dung diem ky nang

# --- 5. Nhat vang ---
func collect_gold(amount: int):
	gold += amount  # Tang so vang cua player
	print("%s collects %d gold!" % [name, amount])  # In ra thong bao nhat vang

# --- 6. Su dung vang ---
func spend_gold(amount: int) -> bool:
	if gold >= amount:  # Neu player co du vang
		gold -= amount  # Giam vang da su dung
		return true
	else:
		print("Not enough gold!")  # In ra thong bao neu khong du vang
		return false

# --- 7. Mua vat pham ---
func buy_item(item, price: int):
	if spend_gold(price):  # Neu player du vang de mua
		add_to_inventory(item)  # Them vat pham vao tui
		print("%s buys %s for %d gold!" % [name, item.name, price])  # In ra thong bao mua vat pham

# --- 8. Nhat vat pham ---
func add_to_inventory(item):
	if inventory.size() < max_inventory_size:  # Neu tui chua day
		inventory.append(item)  # Them vat pham vao tui
		print("%s picks up %s!" % [name, item.name])  # In ra thong bao nhat vat pham
	else:
		print("Inventory is full!")  # In ra thong bao tui day

# --- 9. Ban vat pham ---
func sell_item(item, price: int):
	if inventory.has(item):  # Neu player co vat pham trong tui
		inventory.erase(item)  # Xoa vat pham ra khoi tui
		collect_gold(price)  # Nhap vang tu vi tri ban
		print("%s sells %s for %d gold!" % [name, item.name, price])  # In ra thong bao ban vat pham

# --- 10. Trang bi vat pham ---
func equip_item(item):
	if inventory.has(item):  # Neu player co vat pham trong tui
		equipped_items[item.name] = item  # Trang bi vat pham
		apply_item_stats(item)  # Ap dung cac chi so cua vat pham
		inventory.erase(item)  # Xoa vat pham khoi tui
		print("%s equips %s!" % [name, item.name])  # In ra thong bao trang bi vat pham

# --- 11. Thao bo trang bi ---
func unequip_item(item_name: String):
	if equipped_items.has(item_name):  # Neu player co vat pham trong danh sach trang bi
		var item = equipped_items[item_name]  # Lay vat pham
		remove_item_stats(item)  # Loai bo cac chi so cua vat pham
		inventory.append(item)  # Them vat pham vao tui
		equipped_items.erase(item_name)  # Xoa vat pham khoi danh sach trang bi
		print("%s unequips %s!" % [name, item_name])  # In ra thong bao thao bo trang bi

# --- 12. Ap dung chi so vat pham ---
func apply_item_stats(item):
	health += item.health_bonus  # Tang mau theo bonus cua vat pham
	mana += item.mana_bonus  # Tang mana theo bonus cua vat pham
	defense += item.defense_bonus  # Tang phong thu theo bonus cua vat pham
	damage_attack += item.attack_bonus  # Tang sat thuong theo bonus cua vat pham

# --- 13. Loai bo chi so vat pham ---
func remove_item_stats(item):
	health -= item.health_bonus  # Giam mau theo bonus cua vat pham
	mana -= item.mana_bonus  # Giam mana theo bonus cua vat pham
	defense -= item.defense_bonus  # Giam phong thu theo bonus cua vat pham
	damage_attack -= item.attack_bonus  # Giam sat thuong theo bonus cua vat pham

# --- 14. Su dung vat pham hoi mau ---
func use_health_potion(potion):
	if inventory.has(potion) and potion.type == "health":  # Neu player co potion hoi mau trong tui
		heal(potion.value)  # Hoi mau
		inventory.erase(potion)  # Xoa potion khoi tui
		print("%s uses a health potion!" % name)  # In ra thong bao su dung potion hoi mau

# --- 15. Su dung vat pham hoi KI ---
func use_mana_potion(potion):
	if inventory.has(potion) and potion.type == "mana":  # Neu player co potion hoi mana trong tui
		restore_ki(potion.value)  # Hoi mana
		inventory.erase(potion)  # Xoa potion khoi tui
		print("%s uses a mana potion!" % name)  # In ra thong bao su dung potion hoi mana

# --- 16. Kiem tra tinh trang kiet suc ---
func is_exhausted() -> bool:
	return stamina <= 0  # Kiem tra xem player co kiệt sức hay không

# --- 17. Giam suc benh khi di chuyen ---
func move_with_stamina(position: Vector2):
	if not is_exhausted():  # Neu player khong bi kiệt sức
		move_to_position(position)  # Di chuyen toi vi tri
		stamina -= 10  # Giam suc benh
		print("%s moves to position, stamina left: %d" % [name, stamina])  # In ra thong bao di chuyen
	else:
		print("%s is too exhausted to move!" % name)  # In ra thong bao khi player kiệt sức

# --- 18. Hoi suc benh ---
func restore_stamina(amount: int):
	stamina = min(stamina + amount, max_stamina)  # Hoi suc benh
	print("%s restores %d stamina!" % [name, amount])  # In ra thong bao hoi suc benh

# --- 19. Nhay ---
func jump():
	if not is_exhausted():  # Neu player khong bi kiệt sức
		move_and_slide(Vector2(0, -200))  # Thuc hien nhay
		stamina -= 20  # Giam suc benh
		print("%s jumps!" % name)  # In ra thong bao nhay

# --- 20. Tan cong voi chi so chi mang ---
func critical_attack(target):
	if randf() < 0.25:  # 25% co hoi chi mang
		var critical_damage = damage_attack * 2  # Sat thuong chi mang
		target.take_damage(critical_damage)  # Tinh toan va goi ham take_damage de su ly
		print("%s lands a critical hit for %d damage!" % [name, critical_damage])  # In ra thong bao chi mang

# --- 21. Khoa muc tieu ---
func lock_on_target(target):
	if targets.has(target):  # Neu target ton tai
		print("%s locks on to %s" % [name, target.name])  # In ra thong bao khoa muc tieu

# --- 22. Thoat khoi che do khoa ---
func unlock_target():
	print("%s unlocks from target" % name)  # In ra thong bao thoat che do khoa

# --- 23. Ky nang dac biet hoi phuc ---
func recover_skill():
	if mana >= 15:  # Neu player du mana de su dung ky nang
		mana -= 15  # Giam mana
		heal(20)  # Hoi mau
		print("%s uses recover skill!" % name)  # In ra thong bao su dung ky nang hoi phuc

# --- 24. Ky nang ne tranh ---
func dodge():
	if stamina >= 10:  # Neu player du suc benh
		stamina -= 10  # Giam suc benh
		move_and_slide(Vector2(randf() * 100, 0))  # Thuc hien di chuyen nhanh de ne tranh
		print("%s dodges!" % name)  # In ra thong bao ne tranh

# --- 25. Ky nang pha giap ---
func armor_break(target: CharacterManager):
	if mana >= 20:  # Neu player du mana
		mana -= 20  # Giam mana
		target.defense -= 5  # Giam phong thu cua target
		print("%s uses armor break on %s!" % [name, target.name])  # In ra thong bao su dung pha giap

# --- 26. Hoi sinh ---
func resurrect():
	if status == "dead":  # Neu player dang chet
		status = "alive"  # Hoi sinh player
		health = max_health % 2  # Hoi mau voi 50%
		print("%s is resurrected with half health!" % name)  # In ra thong bao hoi sinh

# --- 27. Cai thien chi so tam thoi ---
func apply_temp_buff(buff_name: String, value: int, duration: float):
	buffs[buff_name] = value  # Them buff vao danh sach buff
	yield(get_tree().create_timer(duration), "timeout")  # Cho het thoi gian buff
	buffs.erase(buff_name)  # Xoa buff khi het thoi gian
	print("%s's %s buff of %d has expired!" % [name, buff_name, value])  # In ra thong bao buff het hieu luc

# --- 28. Cộng dồn buff ---
func stack_buff(buff_name: String, value: int):
	buffs[buff_name] += value  # Tang gia tri buff
	print("%s's %s buff increased by %d!" % [name, buff_name, value])  # In ra thong bao tang buff

# --- 29. Ky nang trieu hoi ---
func summon_pet():
	if mana >= 30:  # Neu player du mana
		mana -= 30  # Giam mana
		print("%s summons a pet to assist!" % name)  # In ra thong bao trieu hoi thu cung

# --- 30. Truy tim kho bau ---
func find_treasure():
	var treasure_found = randi() % 100 < 20  # 20% co hoi tim thay kho bau
	if treasure_found:
		print("%s finds a hidden treasure!" % name)  # In ra thong bao tim thay kho bau
	else:
		print("%s finds nothing!" % name)  # In ra thong bao khong tim thay kho bau

# --- 31. Tim diem yeu ---
func identify_weakness(enemy: CharacterManager):
	if mana >= 10:  # Neu player du mana
		mana -= 10  # Giam mana
		enemy.defense -= 3  # Giam phong thu cua doi thu
		print("%s identifies weakness in %s's defense!" % [name, enemy.name])  # In ra thong bao tim diem yeu

# --- 32. Hanh dong nhanh ---
func quick_action():
	stamina -= 5  # Giam suc benh
	move_and_slide(Vector2(100, 0))  # Thuc hien hanh dong nhanh
	print("%s performs a quick action!" % name)  # In ra thong bao hanh dong nhanh

# --- 33. Tao lop khiên ---
func shield():
	if mana >= 25:  # Neu player du mana
		mana -= 25  # Giam mana
		defense += 10  # Tang chi so phong thu
		print("%s creates a shield!" % name)  # In ra thong bao tao khiên

# --- 34. Lang nghe moi truong ---
func listen_for_clues():
	print("%s listens carefully for any clues." % name)  # In ra thong bao lang nghe moi truong

# --- 35. Goi dong minh ---
func call_for_allies():
	print("%s calls for nearby allies!" % name)  # In ra thong bao goi dong minh

# --- 36. Phat hien bap ---
func detect_trap():
	if randf() < 0.3:  # 30% co hoi phat hien bap
		print("%s detects a trap nearby!" % name)  # In ra thong bao phat hien bap

# --- 37. Tao ho tro phong thu ---
func create_defensive_support():
	print("%s creates a defensive support!" % name)  # In ra thong bao tao ho tro phong thu

# --- 38. Su dung bap ---
func deploy_trap():
	print("%s deploys a trap!" % name)  # In ra thong bao su dung bap

# --- 39. Phat hien doi phuong an nap ---
func detect_hidden_enemy():
	print("%s scans for hidden enemies!" % name)  # In ra thong bao phat hien doi phuong an nap

# --- 40. Tang cuong kha nang tang hinh ---
func enhance_stealth():
	is_hidden = true  # Doi tuong se an
	print("%s enhances stealth mode!" % name)  # In ra thong bao tang cuong tàng hình
