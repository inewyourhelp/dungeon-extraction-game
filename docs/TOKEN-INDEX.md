# 🔖 项目文档索引 (Token 优化专用)

**版本:** v1.0  
**最后更新:** 2026-03-23  

---

## 📁 核心文档结构

```
dungeon-extraction-game/
├── design/
│   ├── COMPLETE-GAMEPLAY-DESIGN-SIMPLIFIED.md (~4,300 字) - 无代码版
│   ├── COMPLETE-GAMEPLAY-DESIGN-V2.md (~2,800 字) - 深度精简版
│   ├── COMPLETE-GAMEPLAY-DESIGN-V3-SUMMARY.md (~1,500 字) - ✅日常参考基准
│   └── PHASE2-DEVELOPMENT-PLAN.md (~1,200 字) - 开发计划草案
├── tasks/
│   └── TASK-002-revision.md - 任务指令
└── docs/
    ├── TOKEN-INDEX.md (本文件) - ✅Token 优化专用索引
    └── KEY-MECHANISMS.md (建议创建) - 核心机制摘要
```

---

## 🎯 日常参考基准 (优先读取小文档)

| 需求 | 推荐文档 | Token/次 |
|------|----------|----------|
| 查看策划概览 | V3-SUMMARY.md | ~50 tokens |
| 确认开发计划 | PHASE2-PLAN.md | ~100 tokens |
| 查阅核心机制 | KEY-MECHANISMS.md (待创建) | ~80 tokens |

---

## 🔥 核心机制摘要 (避免读取大文档)

### 元素反应系统 (七大类型)
```
蒸发 (水 + 火): ×2.0x 瞬间伤害
融化 (冰 + 火): ×1.5x 范围伤害
感电 (电 + 水): ×1.2x/s 连锁伤害
燃烧 (草 + 火): ×0.8x/s 持续伤害
冻结 (水 + 冰): 完全定身 1~2s
超载 (电 + 火): ×1.3x 击退效果
绽放 (草 + 水): 生成种子，可触发额外反应
```

### 增援范围机制
- **半径**: 64px (可调 32~128px)
- **最大数量**: 3 个/次
- **延迟触发**: 0.5s FIFO 队列

### 撤离倒计时
- **警告阶段**: t=600~900s (屏幕闪烁)
- **倒计时显示**: t=900~1200s
- **超时惩罚**: t>1200s, -5%/s 生命上限

---

## 🚫 禁止操作规则

| 场景 | ❌ 禁止 | ✅ 允许 |
|------|--------|---------|
| 日常查阅 | read(COMPLETE-GAMEPLAY-DESIGN.md) | read(V3-SUMMARY.md) |
| 确认机制细节 | read(大文档, offset=0, limit=全量) | read(小文档, offset=X, limit=Y) |
| 重复读取同一文件 | 会话中多次 read() 相同文件 | 记住已读内容，避免重复 |

---

## 📝 待办事项 (BOSS 确认中)

- [ ] SHANGSHU/HUISHI 评审 Phase2 开发计划
- [ ] BOSS 最终确认开发优先级
- [ ] 创建 KEY-MECHANISMS.md (核心机制摘要文件)

---

*维护人：中书 🐉 | 目标：每次请求 <500 tokens*
