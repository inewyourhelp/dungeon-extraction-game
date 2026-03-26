# ElementType.gd - 元素类型枚举
# 🛠️ T-031-A: 元素附着数据结构设计 (Day 1)
# Agent Team - 缮治开发

class_name ElementType
extends RefCounted

## ============================================
## 元素类型定义
## ============================================

enum Element {
	## @description 无元素状态
	NONE = 0,
	
	## 🔥 火系元素
	FIRE,
	
	## 💧 水系元素  
	WATER,
	
	## ❄️ 冰系元素
	ICE,
	
	## ⚡ 雷系元素
	ELECTRO,
	
	## 🌿 草系元素 (原"植物")
	PLANT,
	
	## 💎 岩系元素
	GEO,
	
	## 💨 风系元素
	ANEMO,
	
	## ⚡⚡ 特殊：双元素混合状态 (用于 UI 显示)
	MIXED_FIRE_WATER = -1,  # 蒸发/融化
	MIXED_WATER_ICE = -2,   # 冻结
}

## ============================================
## 静态工具函数
## ============================================

static func get_element_name(element: Element) -> String:
	"""获取元素名称 (用于 UI 显示)"""
	match element:
		Element.NONE: return "无"
		Element.FIRE: return "火"
		Element.WATER: return "水"
		Element.ICE: return "冰"
		Element.ELECTRO: return "雷"
		Element.PLANT: return "草"
		Element.GEO: return "岩"
		Element.ANEMO: return "风"
		_: return "未知"

static func get_element_color(element: Element) -> Color:
	"""获取元素颜色 (用于 UI 显示)"""
	match element:
		Element.FIRE: return Color(0.9, 0.2, 0.1)    # 红色
		Element.WATER: return Color(0.1, 0.4, 0.9)   # 蓝色
		Element.ICE: return Color(0.3, 0.7, 0.9)     # 浅蓝
		Element.ELECTRO: return Color(0.8, 0.6, 0.1) # 黄色
		Element.PLANT: return Color(0.2, 0.8, 0.3)   # 绿色
		Element.GEO: return Color(0.7, 0.6, 0.4)     # 棕色
		Element.ANEMO: return Color(0.9, 0.9, 1.0)   # 白色
		_: return Color.WHITE

static func is_valid(element: Element) -> bool:
	"""检查是否为有效元素 (排除 MIXED 状态)"""
	return element in [Element.FIRE, Element.WATER, Element.ICE, 
	                   Element.ELECTRO, Element.PLANT, Element.GEO, Element.ANEMO]
