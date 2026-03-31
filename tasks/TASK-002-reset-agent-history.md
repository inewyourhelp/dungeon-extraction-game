# TASK-002: 清空中书会话历史并重新发送任务

## 🎯 目标
解决中书会话超限问题，重新启动 fresh session 以完成完整策划案。

## ✅ 执行步骤

### Step 1: 删除中书的 jsonl 文件
```bash
cd "D:/soft/openclaw/尚书/.openclaw/agents/agents2/sessions"
del *.jsonl
```

### Step 2: 重新发送完整策划案任务
通过 sessions_send 发送给中书。

## ⏰ 执行时间
2026-03-18

---
尚书统筹