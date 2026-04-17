# ReactionTrigger.gd - 元素反应触发系统
# 🛠️ T-031-A: 元素附着数据结构设计 (Day 1)
# Agent Team - 缮治开发

class_name ReactionTrigger
extends Node

## ============================================
## 单例访问 (autoload)
## ============================================

var _instance: ReactionTrigger = null

func _ready() -> void:
	"""注册为单例"""
	if _instance == null:
		_instance = self
	else:
		queue_free()


## ============================================
## 核心功能：反应检测与触发
## ============================================

func check_and_trigger_reaction(
	attacker_attachment: ElementAttachment,
	defender_attachment: ElementAttachment
) -> ReactionType:
	"""
	检查并触发元素反应
	
	Args:
		attacker_attachment: 攻击者附着组件 (携带元素)
		defender_attachment: 目标附着组件 (已有元素)
	
	Returns:
		ReactionType: 触发的反应类型
	"""
	if not attacker_attachment or not defender_attachment:
		return ReactionType.NONE
	
	# 检查是否为有效状态
	if not attacker_attachment.is_valid() or not defender_attachment.is_valid():
		return ReactionType.NONE
	
	# 检测反应类型
	var reaction_type = ReactionTable.check_reaction(
		attacker_attachment.element_type,
		defender_attachment.element_type
	)
	
	if reaction_type == ReactionType.NONE:
		# 无反应，直接返回
		return ReactionType.NONE
	
	# ✅ 触发反应！
	print("[ReactionTrigger] 🎯 元素反应触发:")
	print(f"  - 攻击者：{ElementType.get_element_name(attacker_attachment.element_type)}")
	print(f"  - 目标：{ElementType.get_element_name(defender_attachment.element_type)}")
	print(f"  - 反应类型：{ReactionTable.get_reaction_name(reaction_type)}")
	
	# 执行反应效果
	_trigger_effect(reaction_type, attacker_attachment, defender_attachment)
	
	return reaction_type


func _trigger_effect(
	reaction_type: ReactionType,
	attacker: ElementAttachment,
	defender: ElementAttachment
) -> void:
	"""
	执行反应效果 (伤害/控制/护盾等)
	
	Args:
		reaction_type: 反应类型
		attacker: 攻击者附着组件
		defender: 目标附着组件
	"""
	var effect = ReactionTable.get_reaction_effect(reaction_type)
	
	match reaction_type:
		ReactionType.VAPORIZE, ReactionType.MELT:
			# 🔥💧 蒸发/融化 - 伤害倍率类
			_apply_damage_multiplier(
				reaction_type == ReactionType.VAPORIZE ? 2.0 : 1.5,
				attacker, defender
			)
			
		ReactionType.FREEZE:
			# ❄️💧 冻结 - 控制类
			_apply_freeze(defender, effect["duration_seconds"])
			
		ReactionType.OVERLOAD:
			# ⚡🔥 超载 - 范围伤害类
			_apply_aoe_damage(
				defender.global_position,
				effect["radius_meters"],
				effect["aoe_damage_percent"]
			)
			
		ReactionType.BURN:
			# 💨🔥 燃烧 - 持续伤害类
			_apply_dot(defender, effect["dot_damage_percent"], effect["duration_seconds"])
			
		ReactionType.CRYSTALLIZE:
			# 💎⚡ 结晶 - 护盾类
			_apply_shield(defender, effect["shield_percent"], effect["duration_seconds"])


## ============================================
## 子功能：伤害倍率应用
## ============================================

func _apply_damage_multiplier(multiplier: float, attacker: ElementAttachment, defender: ElementAttachment) -> void:
	"""应用伤害倍率 (蒸发/融化)"""
	print(f"[ReactionTrigger] ⚔️ 触发 {ReactionTable.get_reaction_name(ReactionType.VAPORIZE if multiplier == 2.0 else ReactionType.MELT)}!")
	print(f"  - 伤害倍率：×{multiplier}")
	
	# TODO: 调用伤害计算系统应用实际伤害
	# combat_system.apply_damage(multiplier * base_damage)
	
	# 消耗层数
	attacker.consume_stacks(1)
	defender.consume_stacks(1)


## ============================================
## 子功能：冻结控制
## ============================================

func _apply_freeze(target: ElementAttachment, duration: float) -> void:
	"""应用冻结效果 (定身控制)"""
	print(f"[ReactionTrigger] ❄️ 触发 {ReactionTable.get_reaction_name(ReactionType.FREEZE)}!")
	print(f"  - 持续时间：{duration}s")
	
	# TODO: 调用角色控制器施加定身状态
	# character_controller.set_stunned(true, duration)
	
	# 消耗层数
	target.consume_stacks(1)


## ============================================
## 子功能：超载范围伤害
## ============================================

func _apply_aoe_damage(position: Vector2, radius: float, damage_percent: float) -> void:
	"""应用超载爆炸 (AOE 伤害)"""
	print(f"[ReactionTrigger] 💥 触发 {ReactionTable.get_reaction_name(ReactionType.OVERLOAD)}!")
	print(f"  - 爆炸半径：{radius}m")
	print(f"  - 范围伤害：目标最大生命值的 {damage_percent}%")
	
	# TODO: 调用 AOE 伤害系统计算范围内所有敌人受到的伤害
	pass


## ============================================
## 子功能：燃烧持续伤害
## ============================================

func _apply_dot(target: ElementAttachment, dot_percent: float, duration: float) -> void:
	"""应用燃烧持续伤害 (DoT)"""
	print(f"[ReactionTrigger] 🔥 触发 {ReactionTable.get_reaction_name(ReactionType.BURN)}!")
	print(f"  - 持续时间：{duration}s")
	print(f"  - 每秒伤害：目标最大生命值的 {dot_percent}%")
	
	# TODO: 调用持续伤害系统应用 DoT
	target.set_duration(duration)


## ============================================
## 子功能：结晶护盾
## ============================================

func _apply_shield(target: ElementAttachment, shield_percent: float, duration: float) -> void:
	"""应用结晶护盾"""
	print(f"[ReactionTrigger] 💎 触发 {ReactionTable.get_reaction_name(ReactionType.CRYSTALLIZE)}!")
	print(f"  - 护盾值：目标最大生命值的 {shield_percent}%")
	print(f"  - 持续时间：{duration}s")
	
	# TODO: 调用护盾系统应用实际护盾
	pass


## ============================================
## 调试功能
## ============================================

func debug_print_reaction_table() -> void:
	"""打印完整反应表 (调试用)"""
	print("[ReactionTrigger] 📊 元素反应表:")
	for key in reaction_map:
		var att = ElementType.get_element_name(key[0])
		var def = ElementType.get_element_name(key[1])
		var react = ReactionTable.get_reaction_name(reaction_map[key])
		print(f"  - {att} + {def} → {react}")
