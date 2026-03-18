# collision_system.gd - 碰撞系统工具类
# 🛠️ 缮治开发 | Agent Team 程序开发工程师
# 负责：主角与地牢墙壁的碰撞检测，防止穿墙

extends Node2D

## ============================================
## 单例访问
## ============================================

static var instance: CollisionSystem = null \
	"""全局实例引用 (自动初始化)"""


func _ready() -> void:
	"""节点就绪时注册为单例"""
	if instance == null:
		instance = self
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
		is_blocked = false,
		collision_point = Vector2.ZERO,
		distance = max_distance,
		surface_normal = Vector2.RIGHT
	}
	
	if raycaster.is_colliding():
		var collision_data := raycast.get_collision()
		result = {
			is_blocked = true,
			collision_point = collision_data.position,
			distance = collision_data.distance,
			surface_normal = collision_data.normal
		}
	
	return result


static func check_circle_wall_collision(
	circle_shape: CircleShape2D,
	global_position: Vector2,
	collision_layer: int,
	collision_mask: int
) -> Dictionary:
	"""
	圆形碰撞体检测 (适合角色与墙壁的包围盒检测)
	
	Args:
		circle_shape: 圆形形状实例
		global_position: 圆心全局坐标
		collision_layer: 自身碰撞层
		collision_mask: 目标碰撞掩码
	
	Returns:
		Dictionary: {
			has_collision: bool,   # 是否有碰撞
			colliding_objects: Array,  # 碰撞对象列表
		 penetration_depth: float  # 穿透深度 (用于修正位置)
		}
	"""
	var result := {
		has_collision = false,
		colliding_objects = [],
		penetration_depth = 0.0
	}
	
	# 使用空间查询而非射线检测
	var space_state := get_world_2d().direct_space_state
	
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = circle_shape
	query.position = global_position
	query.collision_layer = collision_layer
	query.collision_mask = collision_mask
	query.margin = circle_shape.get_margin()  # 使用形状自身的边距
	
	var collisions := space_state.intersect_shape(query, 10)  # 最大 10 个碰撞点
	
	if len(collisions) > 0:
		result.has_collision = true
		result.colliding_objects = [collisions[i].rid for i in range(len(collisions))]
		
		# 计算最小穿透深度 (用于位置修正)
		for collision in collisions:
			var depth := circle_shape.get_margin() - (global_position - collision.position).length()
			if depth > result.penetration_depth:
				result.penetration_depth = depth
	
	return result


static func resolve_wall_collision(
	character: CharacterBody2D,
	collision_data: Dictionary,
	bounce_factor: float = 0.3
) -> Vector2:
	"""
	解决墙壁碰撞，防止穿墙
	
	Args:
		character: CharacterBody2D 实例 (角色控制器)
		collision_data: 碰撞数据字典 (来自 check_wall_collision)
		bounce_factor: 反弹系数 (0.0-1.0, 用于平滑反弹效果)
	
	Returns:
		Vector2: 修正后的速度向量
	"""
	if not collision_data.is_blocked:
		return character.velocity
	
	var surface_normal := collision_data.surface_normal
	
	# 计算平行于表面的速度分量 (保持滑动效果)
	var parallel_velocity := character.velocity.project(surface_normal)
	
	# 计算垂直于表面的速度分量 (用于反弹/停止)
	var perpendicular_velocity := character.velocity - parallel_velocity
	var bounced_perpendicular := perpendicular_velocity * -bounce_factor
	
	# 组合新的速度向量
	var new_velocity := parallel_velocity + bounced_perpendicular
	
	# 限制最大反弹速度，避免弹飞
	new_velocity = new_velocity.limit_length(character.move_speed)
	
	return new_velocity


## ============================================
## 地牢生成辅助函数
## ============================================

static func generate_dungeon_walls(
	parent: Node2D,
	grid_size: int,
	dimensions: Vector2i,
	wall_texture: Texture2D = null
) -> Array[StaticBody2D]:
	"""
	根据网格生成地牢墙壁
	
	Args:
		parent: 父节点 (用于添加子对象)
		grid_size: 每个格子的像素尺寸
		dimensions: 地牢网格维度 (宽，高)
		wall_texture: 可选的墙壁纹理
	
	Returns:
		Array[StaticBody2D]: 生成的墙壁对象列表
	"""
	var walls := []
	
	for y in range(dimensions.y):
		for x in range(dimensions.x):
			var wall := StaticBody2D.new()
			var collision_shape := CollisionShape2D.new()
			
			# 创建墙壁碰撞形状 (正方形)
			var rect_shape := RectangleShape2D.new()
			rect_size.size = Vector2(grid_size, grid_size)
			
			collision_shape.shape = rect_shape
			wall.add_child(collision_shape)
			
			# 添加墙壁纹理 (可选)
			if wall_texture:
				var sprite := Sprite2D.new()
				sprite.texture = wall_texture
				wall.add_child(sprite)
			
			# 设置位置 (居中于格子中心)
			wal.global_position = Vector2(
				x * grid_size + grid_size / 2,
				y * grid_size + grid_size / 2
			)
			
			parent.add_child(wall)
			walls.append(wall)
	
	return walls
