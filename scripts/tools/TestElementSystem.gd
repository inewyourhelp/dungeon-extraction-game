# TestElementSystem.gd - 元素系统测试脚本
# 🛠️ T-031-A: 元素附着数据结构设计 (Day 1)
# Agent Team - 缮治开发

extends Node2D

## ============================================
## 节点引用
## ============================================

@onready var debug_info: Label = $DebugInfo
@onready var element_display_a: Label = $ElementDisplay_A
@onready var element_display_b: Label = $ElementDisplay_B
@onready var reaction_result: Label = $ReactionResult

@onready var attachment_attacker: ElementAttachment = $ElementAttachment_Attacker
@onready var attachment_target: ElementAttachment = $ElementAttachment_Target


## ============================================
## 测试状态
## ============================================

var _current_element_a: ElementType.Element = ElementType.Element.FIRE
var _current_element_b: ElementType.Element = ElementType.Element.WATER


## ============================================
## 生命周期函数
## ============================================

func _ready() -> void:
	"""初始化测试场景"""
	print("[TestElementSystem] 🚀 元素系统测试场景启动!")
	
	# 设置初始显示
	_update_display()
	
	# 自动触发一次反应检测 (演示用)
	await get_tree().create_timer(1.0).timeout
	_trigger_test_reaction()


func _input(event: InputEvent) -> void:
	"""输入事件处理 (测试控制)"""
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()  # ESC 退出
	
	elif event.is_action_pressed("space"):
		_trigger_test_reaction()  # SPACE 触发反应检测


func _process(_delta: float) -> void:
	"""输入循环 (WASD 切换元素)"""
	if Input.is_key_pressed(KEY_A):
		_current_element_a = ElementType.Element.FIRE
	elif Input.is_key_pressed(KEY_S):
		_current_element_a = ElementType.Element.WATER
	elif Input.is_key_pressed(KEY_D):
		_current_element_a = ElementType.Element.ICE
	elif Input.is_key_pressed(KEY_W):
		_current_element_a = ElementType.Element.ELECTRO
	
	if Input.is_key_pressed(KEY_LEFT):
		_current_element_b = ElementType.Element.FIRE
	elif Input.is_key_pressed(KEY_RIGHT):
		_current_element_b = ElementType.Element.WATER
	elif Input.is_key_pressed(KEY_UP):
		_current_element_b = ElementType.Element.ICE
	elif Input.is_key_pressed(KEY_DOWN):
		_current_element_b = ElementType.Element.ELECTRO
	
	_update_display()


## ============================================
## 核心功能：显示更新
## ============================================

func _update_display() -> void:
	"""更新 UI 显示"""
	element_display_a.text = f"攻击者元素 (A/W/S/D): {ElementType.get_element_name(_current_element_a)}"
	element_display_b.text = f"目标元素 (↑/↓/←/→): {ElementType.get_element_name(_current_element_b)}"


func _trigger_test_reaction() -> void:
	"""手动触发反应检测测试"""
	print("\n[TestElementSystem] 🧪 开始反应检测结果:")
	
	# 模拟附着状态
	attachment_attacker.element_type = _current_element_a
	attachment_target.element_type = _current_element_b
	
	var reaction_type = ReactionTrigger.check_and_trigger_reaction(
		attachment_attacker,
		attachment_target
	)
	
	reaction_result.text = f"反应结果：{ReactionTable.get_reaction_name(reaction_type)}"
	reaction_result.modulate = ReactionTable.get_reaction_color(reaction_type) if reaction_type != ReactionType.NONE else Color.WHITE
	
	print(f"[TestElementSystem] ✅ 反应类型：{ReactionTable.get_reaction_name(reaction_type)}")


## ============================================
## 调试功能
## ============================================

func debug_print_all_combinations() -> void:
	"""打印所有元素组合的反应结果 (调试用)"""
	print("\n[Debug] 📊 完整反应表测试:")
	
	var elements = [
		ElementType.Element.FIRE,
		ElementType.Element.WATER,
		ElementType.Element.ICE,
		ElementType.Element.ELECTRO,
	]
	
	for att in elements:
		for def in elements:
			if att == def or att == ElementType.Element.NONE or def == ElementType.Element.NONE:
				continue
			
			var reaction = ReactionTable.check_reaction(att, def)
			var symbol = "→" if reaction != ReactionType.NONE else "×"
			
			print(f"  {ElementType.get_element_name(att)} {symbol} {ElementType.get_element_name(def)} → {ReactionTable.get_reaction_name(reaction)}")
