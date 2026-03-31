# sessions_send 使用指南

## 📝 命令格式

```bash
sessions_send(
    message: string,      # ✅必需：要发送的消息内容
    sessionKey?: string,   # ❌可选：会话 ID（如 agent:agents7）
    label?: string,        # ❌可选：会话标签（如 shanzhi-dev）
    agentId?: string,      # ❌可选：Agent ID（如 agents7）
    timeoutSeconds?: number # ❌可选：超时时间
)
```

## ⚠️ 重要规则

### 1. **必须提供 sessionKey 或 label**
   - ❌ 错误：只提供 agentId
   - ✅ 正确：`sessionKey: "agent:agents7"` 或 `label: "shanzhi-dev"`

### 2. **不能同时使用 sessionKey + label**
   - ❌ 错误：两者都提供会报 "Provide either sessionKey or label (not both)"
   - ✅ 正确：只选其一

## 🚀 我使用的命令示例

### 尝试 1: 通过 agentId（失败）
```javascript
sessions_send({
    agentId: "agents7",
    message: "任务内容..."
})
// ❌ 错误：Either sessionKey or label is required
```

### 尝试 2: 通过 label（失败 - 会话不存在）
```javascript
sessions_send({
    label: "shanzhi-dev",
    message: "任务内容..."
})
// ❌ 错误：No session found with label: shanzhi-dev
```

### 尝试 3: 通过 sessionKey（成功 - 需要配置）
```javascript
sessions_send({
    sessionKey: "agent:agents7",
    message: "任务内容..."
})
// ✅ 需要 tools.sessions.visibility=all 才能跨 agent 发送
```

## 📋 当前状态

| Agent | Session Key | Status |
|-------|-------------|--------|
| 尚书 (me) | `agent:agents1:feishu:group:...` | ✅ Active |
| **缮治** | `agent:agents7`? | ❌ No session found |

## 💡 解决方案

目前 agents7（缮治）没有活跃会话，需要：
1. 通过 Feishu 群聊@缮治让他主动创建会话，或者
2. 等待系统自动创建 agents7 的会话
