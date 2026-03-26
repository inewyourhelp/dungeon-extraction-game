# ReactionTable.gd - 元素反应表配置
# 🛠️ T-031-A: 元素附着数据结构设计 (Day 1)
# Agent Team - 缮治开发

class_name ReactionTable
extends Node

## ============================================
## 反应类型枚举
## ============================================

enum ReactionType {
	## ⚡ 基础反应
	NONE,              # 无反应
	
	## 🔥💧 蒸发/融化 (伤害倍率类)
	VAPORIZE,          # 火 + 水 = 蒸发 ×2.0x
	MELT,              # 冰 + 火 = 融化 ×1.5x
	
	## ❄️💧 冻结 (控制类)
	FREEZE,            # 水 + 冰 = 冻结定身 1~2s
	
	## ⚡🔥 超载/感电 (范围伤害类)
	OVERLOAD,          # 火 + 雷 = 爆炸范围伤害
	ELECTROCHARGE,     # 雷 + 雷 = 雷盾 (暂不实现)
	
	## 💧💨 燃烧/扩散 (持续伤害类)
	BURN,              # 草 + 火 = 持续火焰伤害
	VAPORIZE_DOT,      # 水 + 风 = 湿气扩散
	
	## 🌿⚡ 绽放系列 (召唤类 - Phase 3+)
	SPROUTING,         # 草 + 雷 = 种子生成
	BLOOM,             # 草 + 水 = 绽放触发
	HYPERSPRING,       # 草 + 火 = 超绽放
	
	## 💎⚡ 结晶 (护盾类)
	CRYSTALLIZE,       # 岩 + 元素 = 结晶护盾
}

## ============================================
## 反应表配置
## ============================================

## @description 核心反应映射表 (攻击者元素 → 目标元素 → 反应类型)
var reaction_map: Dictionary = {
	# 🔥💧 蒸发/融化
	(ElementType.Element.FIRE, ElementType.Element.WATER): ReactionType.VAPORIZE,      # 火打水 → 蒸发 ×2.0x
	(ElementType.Element.WATER, ElementType.Element.FIRE): ReactionType.MELT,          # 水打火 → 融化 ×1.5x
	
	# ❄️💧 冻结
	(ElementType.Element.WATER, ElementType.Element.ICE): ReactionType.FREEZE,         # 水 + 冰 → 冻结定身 1~2s
	(ElementType.Element.ICE, ElementType.Element.WATER): ReactionType.FREEZE,
	
	# ⚡🔥 超载/感电
	(ElementType.Element.FIRE, ElementType.Element.ELECTRO): ReactionType.OVERLOAD,    # 火 + 雷 → 爆炸范围伤害
	(ElementType.Element.ELECTRO, ElementType.Element.FIRE): ReactionType.OVERLOAD,
	
	# 💨🔥 扩散 (待实现)
	# (ElementType.Element.ANEMO, ElementType.Element.FIRE): ReactionType.DIFFUSE,
}

## @description 反应效果配置表
var reaction_effects: Dictionary = {
	ReactionType.VAPORIZE: {
		"damage_multiplier": 2.0,      # ×2.0x 伤害
		"effect_type": "instant",      # 瞬时触发
		"stacks_consumed": {"attacker": 1, "defender": 1}
	},
	
	ReactionType.MELT: {
		"damage_multiplier": 1.5,      # ×1.5x 伤害
		"effect_type": "instant",
		"stacks_consumed": {"attacker": 1, "defender": 1}
	},
	
	ReactionType.FREEZE: {
		"damage_multiplier": 0.0,      # 无直接伤害
		"effect_type": "control",      # 控制效果
		"duration_seconds": 1.5,       # 定身 1~2s (可配置)
		"stacks_consumed": {"attacker": 1, "defender": 1}
	},
	
	ReactionType.OVERLOAD: {
		"damage_multiplier": 1.0,      # 直接伤害为 0
		"effect_type": "aoe_damage",   # 范围爆炸伤害
		"radius_meters": 3.0,          # 爆炸半径
		"aoe_damage_percent": 50,      # 目标最大生命值百分比伤害
		"stacks_consumed": {"attacker": 1, "defender": 1}
	},
	
	ReactionType.BURN: {
		"damage_multiplier": 0.0,      # 直接伤害为 0
		"effect_type": "dot",          # 持续火焰伤害
		"dot_damage_percent": 2.0,     # 每秒目标最大生命值百分比
		"duration_seconds": 5.0,       # 持续 5 秒
		"stacks_consumed": {"attacker": 1, "defender": 1}
	},
	
	ReactionType.CRYSTALLIZE: {
		"damage_multiplier": 0.0,      # 直接伤害为 0
		"effect_type": "shield",       # 结晶护盾
		"shield_percent": 5.0,         # 目标最大生命值百分比护盾
		"duration_seconds": 10.0,      # 护盾持续 10 秒
		"stacks_consumed": {"attacker": 1, "defender": 1}
	},
}

## ============================================
## 静态工具函数
## ============================================

static func get_reaction_name(reaction_type: ReactionType) -> String:
	"""获取反应名称 (用于 UI 显示)"""
	match reaction_type:
		ReactionType.NONE: return "无"
		ReactionType.VAPORIZE: return "蒸发"
		ReactionType.MELT: return "融化"
		ReactionType.FREEZE: return "冻结"
		ReactionType.OVERLOAD: return "超载"
		ReactionType.BURN: return "燃烧"
		ReactionType.CRYSTALLIZE: return "结晶"
		_: return "未知反应"

static func get_reaction_color(reaction_type: ReactionType) -> Color:
	"""获取反应颜色 (用于 UI 显示)"""
	match reaction_type:
		ReactionType.VAPORIZE: return Color(0.9, 0.2, 0.1)    # 红色 (火系)
		ReactionType.MELT: return Color(0.3, 0.7, 0.9)        # 蓝色 (冰系)
		ReactionType.FREEZE: return Color(0.4, 0.6, 1.0)      # 浅蓝
		ReactionType.OVERLOAD: return Color(0.8, 0.4, 0.1)    # 橙色
		ReactionType.BURN: return Color(0.9, 0.5, 0.2)        # 橙色
		ReactionType.CRYSTALLIZE: return Color(0.6, 0.7, 0.8) # 灰色
		_: return Color.WHITE

static func check_reaction(attacker_type: ElementType.Element, defender_type: ElementType.Element) -> ReactionType:
	"""
	检查两个元素是否触发反应
	
	Args:
		attacker_type: 攻击者元素类型
		defender_type: 目标附着元素类型
	
	Returns:
		ReactionType: 触发的反应类型 (无反应返回 NONE)
	"""
	if attacker_type == ElementType.Element.NONE or defender_type == ElementType.Element.NONE:
		return ReactionType.NONE
	
	var key = (attacker_type, defender_type)
	if reaction_map.has(key):
		return reaction_map[key]
	
	return ReactionType.NONE

static func get_reaction_effect(reaction_type: ReactionType) -> Dictionary:
	"""获取反应效果配置"""
	if reaction_effects.has(reaction_type):
		return reaction_effects[reaction_type]
	
	# 默认无伤害、瞬时触发
	return {
		"damage_multiplier": 0.0,
		"effect_type": "none",
		"stacks_consumed": {"attacker": 0, "defender": 0}
	}
