# RelationSystem.gd - NPC 关系值系统核心类
# 🛠️ T-002: NPC 关系值系统实现 (Day 1)
# Agent Team - 缮治开发

class_name RelationSystem
extends Node

## ============================================
## 单例访问 (autoload)
## ============================================

var _instance: RelationSystem = null

func _ready() -> void:
	"""注册为单例"""
	if _instance == null:
		_instance = self
	else:
		queue_free()


## ============================================
## NPC 数据存储
## ============================================

var _npc_cache: Dictionary = {}
## NPC ID → NPCData 映射表


## ============================================
## 核心功能：NPC 管理
## ============================================

func add_npc(npc_data: NPCData) -> void:
	"""添加 NPC 到缓存"""
	if not npc_data or npc_data.npc_id.is_empty():
		warn("[RelationSystem] 无效的 NPC 数据!")
		return
	
	_npc_cache[npc_data.npc_id] = npc_data
	print(f"[RelationSystem] ✅ 添加 NPC: {npc_data.name} (ID: {npc_data.npc_id})")


func get_npc(npc_id: String) -> NPCData:
	"""获取 NPC 数据"""
	if _npc_cache.has(npc_id):
		return _npc_cache[npc_id]
	
	warn(f"[RelationSystem] ❌ NPC 不存在：{npc_id}")
	return null


func remove_npc(npc_id: String) -> bool:
	"""删除 NPC"""
	if _npc_cache.has(npc_id):
		_npc_cache.erase(npc_id)
		print(f"[RelationSystem] 🗑️ 删除 NPC: {npc_id}")
		return true
	
	return false


func list_all_npcs() -> Array[NPCData]:
	"""获取所有 NPC 列表"""
	var npc_list := []
	for key in _npc_cache.keys():
		npc_list.append(_npc_cache[key])
	
	print(f"[RelationSystem] 📋 NPC 总数：{npc_list.size()}")
	return npc_list


## ============================================
## 核心功能：关系值操作
## ============================================

func modify_relation(npc_id: String, amount: int) -> bool:
	"""
	修改玩家与 NPC 的关系值
	
	Args:
		npc_id: NPC ID
		amount: 变化量 (正数增加，负数减少)
	
	Returns:
		bool: 是否成功修改
	"""
	var npc = get_npc(npc_id)
	if not npc:
		return false
	
	var old_state = npc.get_relation_state()
	npc.add_relation(amount)
	var new_state = npc.get_relation_state()
	
	print(f"[RelationSystem] 📊 关系值变化:")
	print(f"  - NPC: {npc.name}")
	print(f"  - 旧状态：{old_state.human_readable()}")
	print(f"  - 新状态：{new_state.human_readable()}")
	
	# 检查状态转换
	if old_state != new_state:
		print(f"[RelationSystem] 🔄 关系状态已转换！{old_state.human_readable()} → {new_state.human_readable()}")
	
	return true


func get_relation(npc_id: String) -> int:
	"""获取当前关系值"""
	var npc = get_npc(npc_id)
	if not npc:
		return -1  # NPC 不存在
	
	return npc.relation_score


## ============================================
## 核心功能：友好/敌对状态转换
## ============================================

func is_friend(npc_id: String) -> bool:
	"""检查是否为好友 (关系值≥40)"""
	var score = get_relation(npc_id)
	if score == -1:
		return false
	
	return score >= 40


func is_enemy(npc_id: String) -> bool:
	"""检查是否为敌对 (关系值<40)"""
	var score = get_relation(npc_id)
	if score == -1:
		return true  # NPC 不存在视为敌对
	
	return score < 40


func is_intimate(npc_id: String) -> bool:
	"""检查是否为亲密 (关系值≥70)"""
	var score = get_relation(npc_id)
	if score == -1:
		return false
	
	return score >= 70


## ============================================
## 核心功能：对话分支触发逻辑
## ============================================

func can_dialogue_with(npc_id: String, required_level: int = 0) -> bool:
	"""
	检查是否满足与 NPC 对话的条件
	
	Args:
		npc_id: NPC ID
		required_level: 所需最小关系值 (默认 0，所有玩家可见)
	
	Returns:
		bool: 是否可以对话
	"""
	var score = get_relation(npc_id)
	if score == -1:
		return false
	
	return score >= required_level


func get_available_dialogue_branches(npc_id: String) -> Array[String]:
	"""获取 NPC 可用的对话分支列表"""
	var npc = get_npc(npc_id)
	if not npc:
		return []
	
	var branches := []
	
	# 根据关系值动态生成对话分支
	match npc.get_relation_state():
		NPCData.RelationState.ENEMY:
			branches.append("敌对对话")
			branches.append("拒绝交易")
			
		NPCData.RelationState.FRIENDLY:
			branches.append("友好对话")
			branches.append("普通任务")
			if npc.npc_type == NPCData.NPCType.VENDOR:
				branches.append("购买商品")
				
		NPCData.RelationState.INTIMATE:
			branches.append("亲密对话")
			branches.append("特殊任务")
			if npc.npc_type == NPCData.NPCType.QUEST_GIVER:
				branches.append("隐藏任务")
	
	return branches


## ============================================
## 数据持久化 (JSON 读写)
## ============================================

func load_npcs_from_json(json_path: String) -> bool:
	"""
	从 JSON 文件加载 NPC 数据
	
	Args:
		json_path: JSON 文件路径
	
	Returns:
		bool: 是否成功加载
	"""
	var file = FileAccess.open(json_path, FileAccess.READ)
	if not file:
		warn(f"[RelationSystem] ❌ 无法打开文件：{json_path}")
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		warn(f"[RelationSystem] ❌ JSON 解析失败：{error}")
		return false
	
	var data = json.data as Array if typeof(json.data) == TYPE_ARRAY else [json.data]
	
	for npc_dict in data:
		var npc_data = NPCData.from_json(npc_dict)
		add_npc(npc_data)
	
	print(f"[RelationSystem] ✅ 从文件加载 {data.size()} 个 NPC")
	return true


func save_npcs_to_json(json_path: String) -> bool:
	"""
	保存 NPC 数据到 JSON 文件
	
	Args:
		json_path: JSON 文件路径
	
	Returns:
		bool: 是否成功保存
	"""
	var data := []
	for npc_id in _npc_cache.keys():
		data.append(_npc_cache[npc_id].to_json())
	
	var json_string = JSON.stringify(data, "\t")
	
	var file = FileAccess.open(json_path, FileAccess.WRITE)
	if not file:
		warn(f"[RelationSystem] ❌ 无法写入文件：{json_path}")
		return false
	
	file.store_string(json_string)
	file.close()
	
	print(f"[RelationSystem] ✅ 保存 {data.size()} 个 NPC 到文件")
	return true


## ============================================
## 调试功能
## ============================================

func debug_print_all_relations() -> void:
	"""打印所有 NPC 关系状态 (调试用)"""
	print("[RelationSystem] 📊 当前所有 NPC 关系:")
	
	for npc_id in _npc_cache.keys():
		var npc = _npc_cache[npc_id]
		npc.debug_print_info()


func debug_test_relationship_changes() -> void:
	"""测试关系值变化 (调试用)"""
	print("[RelationSystem] 🧪 开始关系状态转换测试...")
	
	# 添加测试 NPC
	var test_npc = NPCData.new()
	test_npc.npc_id = "TEST_NPC"
	test_npc.name = "测试 NPC"
	test_npc.relation_score = 0
	
	add_npc(test_npc)
	
	# 模拟关系值变化
	for i in range(10):
		modify_relation("TEST_NPC", 15)
		await get_tree().create_timer(0.3).timeout


## ============================================
## 工具函数
## ============================================

static func _init() -> void:
	"""类初始化 (静态方法)"""
	pass
