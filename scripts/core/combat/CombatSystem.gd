# CombatSystem.gd - 战斗系统核心类
# 🛠️ T-031-B: CombatSystem 集成 (Day 1)
# Agent Team - 缮治开发

class_name CombatSystem
extends Node

## ============================================
## 单例访问 (autoload)
## ============================================

var _instance: CombatSystem = null

func _ready() -> void:
	"""注册为单例"""
	if _instance == null:
		_instance = self
	else:
		queue_free()


## ============================================
## 核心功能：攻击命中时附加层数
## ============================================

func apply_element_attack(
	target_node: Node2D,
	attacker_element_type: ElementType.Element,
	stacks_amount: int = -1
) -> ElementAttachment:
	"""
	对目标施加元素附着
	
	Args:
		target_node: 目标节点 (需包含 ElementAttachment 组件)
		attacker_element_type: 攻击者元素类型
		stacks_amount: 附加层数 (-1=随机 1~3 层)
	
	Returns:
		ElementAttachment: 新创建的附着组件
	"""
	var target_attachment = _get_or_create_attachment(target_node, attacker_element_type)
	
	if stacks_amount == -1:
		# 随机附加 1~3 层
		stacks_amount = randi() % 3 + 1
	
	target_attachment.add_stacks(stacks_amount)
	print("[CombatSystem] ⚔️ 攻击命中！元素附着:")
	print(f"  - 目标：{target_node.name}")
	print(f"  - 元素：{ElementType.get_element_name(attacker_element_type)}")
	print(f"  - 层数：+{stacks_amount} (当前：{target_attachment.layer_count})")
	
	# 检查是否触发反应
	_check_and_trigger_reaction(target_node, attacker_element_type)
	
	return target_attachment


func _get_or_create_attachment(node: Node2D, element_type: ElementType.Element) -> ElementAttachment:
	"""获取或创建目标节点的附着组件"""
	var existing = node.get_node_or_null("ElementAttachment")
	if existing != null:
		return existing
	
	var attachment = ElementAttachment.new()
	attachment.element_type = element_type
	attachment.layer_count = 0
	node.add_child(attachment)
	attachment.name = "ElementAttachment"
	
	return attachment


func _check_and_trigger_reaction(target_node: Node2D, attacker_element_type: ElementType.Element) -> void:
	"""检查并触发反应"""
	var target_attachment = target_node.get_node_or_null("ElementAttachment")
	if not target_attachment or not target_attachment.is_valid():
		return
	
	if target_attachment.element_type == attacker_element_type:
		# 同元素叠加，不触发反应
		return
	
	# 触发反应判定
	var reaction_type = ReactionTrigger.check_and_trigger_reaction(
		ElementAttachment.create_attachment(attacker_element_type, 1),
		target_attachment
	)
	
	if reaction_type != ReactionType.NONE:
		print("[CombatSystem] 🎯 反应已触发！")


## ============================================
## 核心功能：伤害计算系统
## ============================================

func calculate_damage(
	base_damage: float,
	element_multiplier: ElementType.Element,
	target_element: ElementType.Element
) -> float:
	"""
	计算最终伤害 (含元素倍率)
	
	Args:
		base_damage: 基础伤害值
		element_multiplier: 攻击者元素类型
		target_element: 目标附着元素类型
	
	Returns:
		float: 最终伤害值
	"""
	var multiplier = _get_element_multiplier(element_multiplier, target_element)
	return base_damage * multiplier


func _get_element_multiplier(attacker_type: ElementType.Element, defender_type: ElementType.Element) -> float:
	"""获取元素倍率"""
	if attacker_type == defender_type:
		return 1.0  # 同元素，无加成
	
	var reaction = ReactionTable.check_reaction(attacker_type, defender_type)
	match reaction:
		ReactionType.VAPORIZE: return 2.0    # 蒸发 ×2.0x
		ReactionType.MELT: return 1.5         # 融化 ×1.5x
		_: return 1.0                        # 无反应，基础伤害


## ============================================
## 测试验证函数 (用于验收标准)
## ============================================

func test_evaporation_multiplier() -> bool:
	"""测试蒸发伤害×2.0x"""
	var base = 100.0
	var result = calculate_damage(base, ElementType.Element.FIRE, ElementType.Element.WATER)
	
	if abs(result - 200.0) < 0.1:
		print("[CombatSystem] ✅ 蒸发伤害验证通过：×{result/base}")
		return true
	else:
		print(f"[CombatSystem] ❌ 蒸发伤害验证失败：期望 200.0, 实际 {result}")
		return false


func test_melt_multiplier() -> bool:
	"""测试融化伤害×1.5x"""
	var base = 100.0
	var result = calculate_damage(base, ElementType.Element.WATER, ElementType.Element.FIRE)
	
	if abs(result - 150.0) < 0.1:
		print("[CombatSystem] ✅ 融化伤害验证通过：×{result/base}")
		return true
	else:
		print(f"[CombatSystem] ❌ 融化伤害验证失败：期望 150.0, 实际 {result}")
		return false


## ============================================
## 调试功能
## ============================================

func debug_print_all_elements() -> void:
	"""打印所有元素名称 (调试用)"""
	var elements = [
		ElementType.Element.FIRE,
		ElementType.Element.WATER,
		ElementType.Element.ICE,
		ElementType.Element.ELECTRO,
	]
	
	for element in elements:
		print(f"{ElementType.get_element_name(element)}")
