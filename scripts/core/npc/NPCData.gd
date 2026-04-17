# NPCData.gd - NPC 数据结构类
# 🛠️ T-001: NPC JSON 数据结构设计 (Day 1)
# Agent Team - 缮治开发

class_name NPCData
extends RefCounted

## ============================================
## NPC 基础信息字段
## ============================================

var npc_id: String = ""
## @description NPC 唯一标识符 (UUID 或 ID 编码)

var name: String = "无名 NPC"
## @description NPC 名称

var description: String = ""
## @description NPC 背景描述/简介

@export_group("📊 关系值系统")

var relation_score: int = 0
## @description 玩家与 NPC 的关系值 (0~100)
## - 0-39: 陌生/敌对状态
## - 40-69: 友好状态  
## - 70-100: 亲密状态

@export_group("🎭 对话系统")

var min_relation_for_dialogue: int = 0
## @description 触发对话所需的最小关系值 (默认 0，所有玩家可见)

var dialogue_tree_id: String = ""
## @description 关联的对话树 ID (用于加载对应对话分支)

@export_group("🏠 NPC 类型")

enum NPCType {
	NONE,           # 无类型
	VENDOR,         # 商人/交易 NPC
	QUEST_GIVER,    # 任务发布者
	ALIANCE_MEMBER, # 盟友成员
	ENEMY,          # 敌对 NPC
	NEUTRAL,        # 中立 NPC (默认)
}

var npc_type: NPCType = NPCType.NEUTRAL
## @description NPC 类型分类

@export_group("🎨 美术资源")

var sprite_id: String = ""
## @description 精灵图 ID (对应绘事的美术资源需求)

var dialogue_sprite_id: String = ""
## @description 对话界面显示的头像/立绘 ID


## ============================================
## 关系值状态判断
## ============================================

func get_relation_state() -> RelationState:
	"""获取当前关系值对应的状态"""
	if relation_score < 40:
		return RelationState.ENEMY
	elif relation_score < 70:
		return RelationState.FRIENDLY
	else:
		return RelationState.INTIMATE


enum RelationState {
	ENEMY,        # 敌对状态 (0-39)
	FRIENDLY,     # 友好状态 (40-69)  
	INTIMATE      # 亲密状态 (70-100)
}


## ============================================
## 关系值操作函数
## ============================================

func add_relation(amount: int) -> void:
	"""增加关系值 (自动保护范围 0~100)"""
	relation_score = clamp(relation_score + amount, 0, 100)


func sub_relation(amount: int) -> bool:
	"""
	减少关系值
	
	Returns:
		bool: 是否成功减少 (未达到下限)
	"""
	if relation_score >= amount:
		relation_score -= amount
		return true
	else:
		relation_score = max(0, relation_score - amount)
		return false


## ============================================
## 工厂方法：从 JSON 加载数据
## ============================================

static func from_json(json_data: Dictionary) -> NPCData:
	"""
	从 JSON 字典创建 NPC 实例
	
	Args:
		json_data: JSON 格式的数据字典
	
	Returns:
		NPCData: 新创建的 NPC 实例
	"""
	var npc = NPCData.new()
	
	npc.npc_id = json_data.get("id", "unknown")
	npc.name = json_data.get("name", "无名 NPC")
	npc.description = json_data.get("description", "")
	npc.relation_score = clamp(json_data.get("relation_score", 0), 0, 100)
	npc.min_relation_for_dialogue = clamp(json_data.get("min_relation_for_dialogue", 0), 0, 100)
	npc.dialogue_tree_id = json_data.get("dialogue_tree_id", "")
	
	if json_data.has("npc_type"):
		match str(json_data["npc_type"]):
			"VENDOR": npc.npc_type = NPCType.VENDOR
			"QUEST_GIVER": npc.npc_type = NPCType.QUEST_GIVER
			"ALIANCE_MEMBER": npc.npc_type = NPCType.ALIANCE_MEMBER
			"ENEMY": npc.npc_type = NPCType.ENEMY
			_: npc.npc_type = NPCType.NEUTRAL
	
	npc.sprite_id = json_data.get("sprite_id", "")
	npc.dialogue_sprite_id = json_data.get("dialogue_sprite_id", "")
	
	return npc


## ============================================
## 工厂方法：保存为 JSON
## ============================================

func to_json() -> Dictionary:
	"""将 NPC 数据序列化为 JSON 字典"""
	return {
		"id": npc_id,
		"name": name,
		"description": description,
		"relation_score": relation_score,
		"min_relation_for_dialogue": min_relation_for_dialogue,
		"dialogue_tree_id": dialogue_tree_id,
		"npc_type": _get_npc_type_string(),
		"sprite_id": sprite_id,
		"dialogue_sprite_id": dialogue_sprite_id
	}


func _get_npc_type_string() -> String:
	"""获取 NPC 类型字符串表示"""
	match npc_type:
		NPCType.VENDOR: return "VENDOR"
		NPCType.QUEST_GIVER: return "QUEST_GIVER"
		NPCType.ALIANCE_MEMBER: return "ALIANCE_MEMBER"
		NPCType.ENEMY: return "ENEMY"
		_: return "NEUTRAL"


## ============================================
## 调试功能
## ============================================

func debug_print_info() -> void:
	"""打印 NPC 信息 (调试用)"""
	print("[NPCData] NPC 信息:")
	print(f"  - ID: {npc_id}")
	print(f"  - 名称：{name}")
	print(f"  - 类型：{_get_npc_type_string()}")
	print(f"  - 关系值：{relation_score}/100 ({get_relation_state().human_readable()})")


func _on_ready() -> void:
	"""节点就绪时初始化 (可选扩展)"""
	pass
