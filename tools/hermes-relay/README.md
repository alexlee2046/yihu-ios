# Hermes Relay Server for Yihu (一呼)

独立、开源的轻量级 Hermes / Agent 中继服务器，专为「一呼」iOS 端的 **ActivityKit Push-to-Start** 与 **灵动岛/锁屏实时活动（Live Activity）** 任务流设计。

---

## 核心特性

1. **Push-to-Start 远程点亮**：当用户在桌面或 WebUI 启动 Agent 任务时，向手机推送启动指令，自动弹出灵动岛。
2. **防 APNs 配额耗尽去抖机制 (Throttling / Debouncing)**：
   - Apple 对 Live Activity APNs 频次有每小时预算限制；
   - 本中继内置 2.5 秒更新合并与限频窗口，避免 Agent 密集调用工具（如连发 10 条 terminal 命令）耗尽全天推送配额。
3. **零密钥客户端设计**：
   - APNs `.p8` 私钥完全保留在用户自建的 Relay 服务器端，iPhone 客户端零凭据存储。
   - 适配 Tailscale Serve 部署，私密安全。

---

## 快速部署指南

### 1. 准备 Apple APNs 凭证
从 [Apple Developer 门户](https://developer.apple.com/account/resources/authkeys/list) 创建一个支持 **Apple Push Notifications service (APNs)** 的 AuthKey：
- 获取 `.p8` 私钥文件并命名为 `AuthKey.p8`，放入 `./data/` 目录；
- 记下 Key ID（如 `AB12CD34EF`）与 Team ID（如 `XY98ZW76VU`）。

### 2. 本地快速启动 (Python 直接运行)

```bash
chmod +x relay_server.py
python3 relay_server.py \
  --port 9444 \
  --key ./data/AuthKey.p8 \
  --key-id XXXXXXXXXX \
  --team-id YYYYYYYYYY \
  --bundle-id org.example.yihu
```

### 3. Docker 容器化部署

```bash
# 复制配置文件
mkdir -p data
cp /path/to/your/AuthKey.p8 data/AuthKey.p8

# 启动容器
docker compose up -d
```

### 4. 接入 Tailscale Serve (推荐安全架构)

```bash
# 将本地 9444 端口通过 Tailscale 私有网格暴露为 HTTPS
tailscale serve https / http://127.0.0.1:9444
```

在「一呼」iOS 设置中，填入你的 Tailnet 域名（如 `https://relay.my-tailnet.ts.net`），即可秒级开启灵动岛远程监控！

---

## Agent / Hermes 状态上报 API

当你的 Agent（或 Hermes 后端）执行步骤时，只需向 Relay 发送一个轻量 HTTP POST 请求：

```bash
curl -X POST https://127.0.0.1:9444/v1/notify \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "task-abc-123",
    "phase": "running",
    "tool_name": "terminal",
    "started_at": 1712880000,
    "url": "https://hermes.my-tailnet.ts.net:9444/session/task-abc-123"
  }'
```

- `phase`: 可选 `running`（进行中）、`done`（已完成）、`failed`（失败）、`interrupted`（已中断）
- `tool_name`: 可选 `terminal`（终端命令）、`patch` / `write_file`（修改文件）、`file_read`（读取文件）、`search`（搜索）、`browser`（浏览器）
