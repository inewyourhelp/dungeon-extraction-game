# TestCombatSystem.gd - 战斗系统测试脚本
# 🛠️ T-031-B: CombatSystem 集成 (Day 1)
# Agent Team - 缮治开发

extends Node2D

## ============================================
## 节点引用
## ============================================

@onready var debug_info: Label = $DebugInfo
@onready var evaporation_result: Label = $EvaporationResult
@onready var melt_result: Label = $MeltResult
@onready var test_target: Node2D = $TestTarget


## ============================================
## 生命周期函数
## ============================================

func _ready() -> void:
	"""初始化测试场景"""
	print("[TestCombatSystem] 🚀 战斗系统测试场景启动!")
	
	# 等待一帧后开始自动验证
	await get_tree().create_timer(0.5).timeout
	_run_tests()


func _run_tests() -> void:
	"""运行所有测试用例"""
	var all_passed = true
	
	# 测试 1: 蒸发伤害×2.0x
	print("\n[TestCombatSystem] 🧪 开始蒸发伤害验证...")
	evaporation_result.text = "蒸发伤害 (火→水): 测试中..."
	
	var fire_attack_success = _test_fire_attack_on_water()
	if fire_attack_success:
		evaporation_result.modulate = Color.GREEN
	else:
		evaporation_result.modulate = Color.RED
		all_passed = false
	
	await get_tree().create_timer(0.5).timeout
	
	# 测试 2: 融化伤害×1.5x
	print("\n[TestCombatSystem] 🧪 开始融化伤害验证...")
	melt_result.text = "融化伤害 (水→火): 测试中..."
	
	var water_attack_success = _test_water_attack_on_fire()
	if water_attack_success:
		melt_result.modulate = Color.GREEN
	else:
		melt_result.modulate = Color.RED
		all_passed = false
	
	await get_tree().create_timer(0.5).timeout
	
	# 最终结果
	print("\n[TestCombatSystem] 📊 测试完成!")
	if all_passed:
		debug_info.text = "✅ 所有测试通过!"
		debug_info.modulate = Color.GREEN
	else:
		debug_info.text = "❌ 部分测试失败"
		debug_info.modulate = Color.RED


func _test_fire_attack_on_water() -> bool:
	"""测试火元素攻击水附着目标 (蒸发×2.0x)"""
	# 设置目标为 WATER 附着
	test_target.get_node("ElementAttachment_Target").element_type = ElementType.Element.WATER
	
	# 模拟攻击
	var attachment = apply_element_attack(
		test_target,
		ElementType.Element.FIRE,
		1  # 附加 1 层火元素
	)
	
	# 验证伤害倍率
	if not attachment or attachment.layer_count != 2:
		print("[TestCombatSystem] ❌ 蒸发测试失败：层数异常")
		return false
	
	var base_damage = 100.0
	var final_damage = calculate_damage(base_damage, ElementType.Element.FIRE, ElementType.Element.WATER)
	
	if abs(final_damage - 200.0) < 0.1:
		evaporation_result.text = f"✅ 蒸发伤害 (火→水): ×{final_damage/base_damage}"
		return true
	else:
		evaporation_result.text = f"❌ 蒸发伤害失败：期望×2.0, 实际×{final_damage/base_damage}"
		return false


func _test_water_attack_on_fire() -> bool:
	"""测试水元素攻击火附着目标 (融化×1.5x)"""
	# 设置目标为 FIRE 附着
	test_target.get_node("ElementAttachment_Target").element_type = ElementType.Element.FIRE
	
	# 模拟攻击
	var attachment = apply_element_attack(
		test_target,
		ElementType.Element.WATER,
		1  # 附加 1 层水元素
	)
	
	# 验证伤害倍率
	if not attachment or attachment.layer_count != 2:
		print("[TestCombatSystem] ❌ 融化测试失败：层数异常")
		return false
	
	var base_damage = 100.0
	var final_damage = calculate_damage(base_damage, ElementType.Element.WATER, ElementType.Element.FIRE)
	
	if abs(final_damage - 150.0) < 0.1:
		melt_result.text = f"✅ 融化伤害 (水→火): ×{final_damage/base_damage}"
		return true
	else:
		melt_result.text = f"❌ 融化伤害失败：期望×1.5, 实际×{final_damage/base_damage}"
		return false
