# collision_system.gd - 碰撞系统工具类
# 🛠️ 缮治开发 | Agent Team 程序开发工程师
# 负责：主角与地牢墙壁的碰撞检测，防止穿墙

extends Node2D

## ============================================
## 单例访问
## ============================================

var _instance: CollisionSystem = null
## 全局实例引用 (自动初始化)


func _ready() -> void:
	"""节点就绪时注册为单例"""
	if _instance == null:
		_instance = self as CollisionSystem
	else:
		queue_free()  # 如果已存在，销毁当前实例


## ============================================
## 碰撞检测工具函数
## ============================================

static func check_wall_collision(
	raycaster: RayCast2D,
	start: Vector2,
	direction: Vector2,
	max_distance: float,
	collision_mask: int = 1
) -> Dictionary:
	"""
	射线检测前方是否有墙壁
	
	Args:
		raycaster: RayCast2D 实例 (用于配置碰撞层/掩码)
		start: 射线起点 (角色中心)
		direction: 检测方向 (归一化向量)
		max_distance: 最大检测距离
		collision_mask: 碰撞掩码 (默认检测墙壁层)
	
	Returns:
		Dictionary: {
			is_blocked: bool,      # 是否被阻挡
			collision_point: Vector2,  # 碰撞点位置
			distance: float,       # 实际检测距离
			surface_normal: Vector2  # 表面法向量 (用于反弹)
		}
	"""
	raycaster.target_position = direction * max_distance
	
	# 临时设置起点，避免修改全局位置
	var original_global_position := raycaster.global_position
	raycaster.global_position = start
	
	# 执行检测
	raycaster.force_raycast_update()
	
	# 恢复原始位置
	raycaster.global_position = original_global_position
	
	var result: Dictionary = {
		"is_blocked": false,
		"collision_point": Vector2.ZERO,
		"distance": max_distance,
		"surface_normal": Vector2.RIGHT
	}
	
	if raycaster.is_colliding():
		var collision_data := raycast.get_collision()
		result["is_blocked"] = true
		result["collision_point"] = collision_data.position
		result["distance"] = collision_data.distance
		result["surface_normal"] = collision_data.normal
	
	return result
