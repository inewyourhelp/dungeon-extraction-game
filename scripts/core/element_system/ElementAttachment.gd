# ElementAttachment.gd - 元素附着组件
# 🛠️ T-031-A: 元素附着数据结构设计 (Day 1)
# Agent Team - 缮治开发

class_name ElementAttachment
extends Node2D

## ============================================
## 导出配置参数
## ============================================

@export_group("🔥 元素属性")

@export var element_type: ElementType.Element = ElementType.Element.NONE
## @description 元素类型 (火/水/冰等)

@export_group("⚡ 层数管理")

@export var layer_count: int = 0
## @description 当前附着层数 (0~3)

@export var max_stacks: int = 3
## @description 最大层数上限 (默认 3 层)

@export_group("⏱️ 持续时间 (DoT 用)")

@export var duration: float = 0.0
## @description 持续时间 (秒，持续伤害效果使用)

@export_group("👁️ 调试信息")

@export var debug_show_layer_ui: bool = false
## @description 是否显示层数 UI(调试用)


## ============================================
## 私有变量
## ============================================

var _timer: float = 0.0
## 当前计时器 (用于 DoT 持续时间)

var _is_active: bool = true
## 是否处于激活状态


## ============================================
## 生命周期函数
## ============================================

func _ready() -> void:
	"""节点就绪时初始化"""
	if layer_count > max_stacks:
		warn("[ElementAttachment] 层数超过上限，已自动修正")
		layer_count = max_stacks
	
	print("[ElementAttachment] 元素附着组件已初始化:")
	print(f"  - 类型：{ElementType.get_element_name(element_type)}")
	print(f"  - 当前层数：{layer_count}/{max_stacks}")


func _process(delta: float) -> void:
	"""每帧更新 (DoT 持续时间处理)"""
	if not _is_active or duration <= 0.0:
		return
	
	_timer += delta
	
	if _timer >= duration and layer_count > 0:
		_expire_effect()


## ============================================
## 核心功能：层数管理
## ============================================

func add_stacks(amount: int) -> void:
	"""
	增加附着层数 (自动保护上限)
	
	Args:
		amount: 要增加的层数
	"""
	if not _is_active:
		warn("[ElementAttachment] 组件已失效，无法增加层数")
		return
	
	var old_count = layer_count
	layer_count = clamp(layer_count + amount, 0, max_stacks)
	
	if layer_count > old_count:
		print("[ElementAttachment] 层数增加：{old_count} → {layer_count}")
		
		# 达到上限时触发提示 (可选扩展)
		if layer_count >= max_stacks:
			print("[ElementAttachment] ⚠️ 已达到最大层数限制!")


func consume_stacks(amount: int) -> bool:
	"""
	消耗附着层数
	
	Args:
		amount: 要消耗的层数
	
	Returns:
		bool: 是否成功消耗
	"""
	if not _is_active or layer_count < amount:
		return false
	
	var old_count = layer_count
	layer_count -= amount
	
	print("[ElementAttachment] 层数消耗：{old_count} → {layer_count}")
	
	# 层数为 0 时自动失效 (可扩展为销毁节点)
	if layer_count <= 0:
		set_active(false)
	
	return true


func consume_all() -> void:
	"""立即清除所有附着层数"""
	layer_count = 0
	print("[ElementAttachment] ⚠️ 已清空所有附着层数")


## ============================================
## 核心功能：状态管理
## ============================================

func set_active(active: bool) -> void:
	"""激活/失效组件"""
	_is_active = active
	
	if not _is_active:
		print("[ElementAttachment] 🚫 元素附着已失效 (层数：{layer_count})")


func is_valid() -> bool:
	"""检查是否为有效附着状态"""
	return _is_active and layer_count > 0


## ============================================
## 核心功能：DoT 持续时间处理
## ============================================

func set_duration(secs: float) -> void:
	"""设置持续伤害持续时间"""
	duration = max(0.0, secs)
	_timer = 0.0
	
	if duration > 0.0:
		print(f"[ElementAttachment] ⏱️ DoT 持续时间设置为：{duration}s")


func _expire_effect() -> void:
	"""持续时间结束时的处理 (可扩展为触发反应/伤害计算)"""
	print("[ElementAttachment] ⏰ DoT 持续时间已结束!")
	
	# 可扩展逻辑：
	# - 触发持续伤害计算
	# - 自动消耗层数
	# - 销毁节点
	
	set_active(false)


## ============================================
## 调试功能
## ============================================

func _debug_render() -> void:
	"""显示层数 UI(仅调试模式)"""
	if not debug_show_layer_ui or layer_count <= 0:
		return
	
	# TODO: 实现层数数字绘制 (可复用 T-034 的 HUD 系统)
	pass


## ============================================
## 静态工具函数
## ============================================

static func create_attachment(element_type: ElementType.Element, stacks: int = 1) -> ElementAttachment:
	"""
	工厂方法：创建元素附着组件
	
	Args:
		element_type: 元素类型
		stacks: 初始层数 (默认 1)
	
	Returns:
		ElementAttachment: 新创建的实例
	"""
	var attachment = ElementAttachment.new()
	attachment.element_type = element_type
	attachment.layer_count = clamp(stacks, 0, 3)
	return attachment
