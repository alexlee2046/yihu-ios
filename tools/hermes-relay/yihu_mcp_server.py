#!/usr/bin/env python3
"""
Yihu Model Context Protocol (MCP) Server & CLI Bridge
=====================================================
Allows autonomous agents (Claude Code, Cursor, OpenHands, Devin, etc.) to report
task progress, tool executions, and approval requests directly to Yihu for iOS
and watchOS Live Activities and Dynamic Island.

Implements standard MCP JSON-RPC 2.0 protocol over stdio with ZERO third-party
dependencies (pure Python 3 standard library).

Usage as MCP Server (in claude.json or cursor settings):
    {
      "mcpServers": {
        "yihu": {
          "command": "python3",
          "args": ["/path/to/tools/hermes-relay/yihu_mcp_server.py"],
          "env": {
            "YIHU_RELAY_URL": "http://127.0.0.1:9444"
          }
        }
      }
    }

Usage as CLI:
    python3 yihu_mcp_server.py notify --session-id "task-001" --agent "Claude Code" --tool "run_command" --phase "running"
    python3 yihu_mcp_server.py approval --session-id "task-001" --agent "Claude Code" --action "Execute database migration"
"""

import sys
import os
import json
import time
import argparse
import urllib.request
import urllib.error

DEFAULT_RELAY_URL = os.environ.get("YIHU_RELAY_URL", "http://127.0.0.1:9444")

# MCP Tool Definitions
TOOLS = [
    {
        "name": "notify_yihu_task",
        "description": "Report agent progress or tool execution to Yihu, updating the user's Dynamic Island and Apple Watch Live Activity in real time.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "session_id": {
                    "type": "string",
                    "description": "Unique session or task identifier."
                },
                "agent_name": {
                    "type": "string",
                    "description": "Name of the agent (e.g. 'Claude Code', 'Cursor', 'OpenHands', 'Devin'). Defaults to 'Agent'."
                },
                "phase": {
                    "type": "string",
                    "enum": ["running", "done", "failed", "interrupted"],
                    "description": "Execution phase. Use 'running' for ongoing steps, 'done' when task completes, 'failed' on error."
                },
                "tool_name": {
                    "type": "string",
                    "description": "Current tool or action name (e.g. 'run_command', 'edit_file', 'web_search', 'test', 'build')."
                },
                "status_message": {
                    "type": "string",
                    "description": "Short human-readable summary of the current step."
                },
                "url": {
                    "type": "string",
                    "description": "Optional deep link or web URL for the user to open when tapping the Live Activity."
                },
                "relay_url": {
                    "type": "string",
                    "description": "Optional relay server URL override."
                }
            },
            "required": ["session_id"]
        }
    },
    {
        "name": "request_human_approval",
        "description": "Request micro-approval from the user on Apple Watch or iPhone before executing a potentially destructive command.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "session_id": {
                    "type": "string",
                    "description": "Unique session or task identifier."
                },
                "agent_name": {
                    "type": "string",
                    "description": "Name of the agent."
                },
                "action_summary": {
                    "type": "string",
                    "description": "Description of the high-risk action requiring approval (e.g. 'Delete 12 files', 'Push to main branch')."
                },
                "relay_url": {
                    "type": "string",
                    "description": "Optional relay server URL override."
                }
            },
            "required": ["session_id", "action_summary"]
        }
    }
]


def post_to_relay(relay_url: str, endpoint: str, payload: dict, timeout: float = 3.0) -> dict:
    url = f"{relay_url.rstrip('/')}{endpoint}"
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=data,
        headers={"Content-Type": "application/json", "User-Agent": "Yihu-MCP-Bridge/1.0"},
        method="POST"
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as response:
            body = response.read().decode("utf-8")
            return json.loads(body) if body else {"status": "ok"}
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8")
        return {"error": f"HTTP {e.code}: {body or e.reason}"}
    except Exception as e:
        return {"error": f"Connection failed: {str(e)}"}


def handle_notify_task(args: dict) -> dict:
    session_id = args.get("session_id")
    if not session_id:
        return {"error": "Missing required argument 'session_id'"}

    relay_url = args.get("relay_url") or DEFAULT_RELAY_URL
    agent_name = args.get("agent_name") or "Agent"
    phase = args.get("phase", "running")
    tool_name = args.get("tool_name")
    status_message = args.get("status_message")
    url = args.get("url")

    payload = {
        "session_id": session_id,
        "agent_name": agent_name,
        "phase": phase,
        "tool_name": tool_name,
        "status": status_message,
        "url": url,
        "started_at": time.time()
    }

    result = post_to_relay(relay_url, "/v1/notify", payload)
    return result


def handle_approval_request(args: dict) -> dict:
    session_id = args.get("session_id")
    action_summary = args.get("action_summary")
    if not session_id or not action_summary:
        return {"error": "Missing required arguments 'session_id' or 'action_summary'"}

    relay_url = args.get("relay_url") or DEFAULT_RELAY_URL
    agent_name = args.get("agent_name") or "Agent"

    payload = {
        "session_id": session_id,
        "agent_name": agent_name,
        "phase": "running",
        "tool_name": "prompt_approval",
        "status": f"微审批请求: {action_summary}",
        "started_at": time.time()
    }

    result = post_to_relay(relay_url, "/v1/notify", payload)
    return result


def process_mcp_message(msg: dict) -> dict | None:
    msg_id = msg.get("id")
    method = msg.get("method")
    params = msg.get("params", {})

    if method == "initialize":
        return {
            "jsonrpc": "2.0",
            "id": msg_id,
            "result": {
                "protocolVersion": "2024-11-05",
                "capabilities": {
                    "tools": {}
                },
                "serverInfo": {
                    "name": "yihu-mcp",
                    "version": "1.0.0"
                }
            }
        }

    elif method == "notifications/initialized":
        return None

    elif method == "ping":
        return {
            "jsonrpc": "2.0",
            "id": msg_id,
            "result": {}
        }

    elif method == "tools/list":
        return {
            "jsonrpc": "2.0",
            "id": msg_id,
            "result": {
                "tools": TOOLS
            }
        }

    elif method == "tools/call":
        tool_name = params.get("name")
        tool_args = params.get("arguments", {})

        if tool_name == "notify_yihu_task":
            res = handle_notify_task(tool_args)
            return {
                "jsonrpc": "2.0",
                "id": msg_id,
                "result": {
                    "content": [
                        {
                            "type": "text",
                            "text": json.dumps(res, ensure_ascii=False)
                        }
                    ]
                }
            }
        elif tool_name == "request_human_approval":
            res = handle_approval_request(tool_args)
            return {
                "jsonrpc": "2.0",
                "id": msg_id,
                "result": {
                    "content": [
                        {
                            "type": "text",
                            "text": json.dumps(res, ensure_ascii=False)
                        }
                    ]
                }
            }
        else:
            return {
                "jsonrpc": "2.0",
                "id": msg_id,
                "error": {
                    "code": -32601,
                    "message": f"Method/Tool not found: {tool_name}"
                }
            }

    else:
        if msg_id is not None:
            return {
                "jsonrpc": "2.0",
                "id": msg_id,
                "error": {
                    "code": -32601,
                    "message": f"Method not supported: {method}"
                }
            }
        return None


def run_stdio_server():
    """Run JSON-RPC 2.0 loop reading from stdin and writing to stdout."""
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            msg = json.loads(line)
        except json.JSONDecodeError as e:
            err_resp = {
                "jsonrpc": "2.0",
                "id": None,
                "error": {"code": -32700, "message": f"Parse error: {str(e)}"}
            }
            sys.stdout.write(json.dumps(err_resp) + "\n")
            sys.stdout.flush()
            continue

        resp = process_mcp_message(msg)
        if resp is not None:
            sys.stdout.write(json.dumps(resp, ensure_ascii=False) + "\n")
            sys.stdout.flush()


def run_self_test():
    """Run self-tests verifying MCP protocol compatibility."""
    print("Testing MCP initialize...")
    init_msg = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {"protocolVersion": "2024-11-05"}
    }
    resp = process_mcp_message(init_msg)
    assert resp["id"] == 1
    assert resp["result"]["serverInfo"]["name"] == "yihu-mcp"

    print("Testing MCP tools/list...")
    list_msg = {
        "jsonrpc": "2.0",
        "id": 2,
        "method": "tools/list",
        "params": {}
    }
    resp = process_mcp_message(list_msg)
    assert resp["id"] == 2
    tool_names = [t["name"] for t in resp["result"]["tools"]]
    assert "notify_yihu_task" in tool_names
    assert "request_human_approval" in tool_names

    print("Testing MCP tools/call missing args error handling...")
    call_msg = {
        "jsonrpc": "2.0",
        "id": 3,
        "method": "tools/call",
        "params": {"name": "notify_yihu_task", "arguments": {}}
    }
    resp = process_mcp_message(call_msg)
    assert resp["id"] == 3
    content = json.loads(resp["result"]["content"][0]["text"])
    assert "error" in content

    print("All MCP self-tests PASSED! ✅")


def main():
    parser = argparse.ArgumentParser(description="Yihu MCP Server & CLI Bridge")
    subparsers = parser.add_subparsers(dest="command")

    # CLI notify subcommand
    notify_cmd = subparsers.add_parser("notify", help="Send a task update to Yihu Relay")
    notify_cmd.add_argument("--session-id", required=True, help="Task or session ID")
    notify_cmd.add_argument("--agent", default="Agent", help="Agent display name")
    notify_cmd.add_argument("--phase", choices=["running", "done", "failed", "interrupted"], default="running")
    notify_cmd.add_argument("--tool", help="Tool name")
    notify_cmd.add_argument("--status", help="Status message")
    notify_cmd.add_argument("--url", help="URL to open on tap")
    notify_cmd.add_argument("--relay-url", default=DEFAULT_RELAY_URL, help="Relay server URL")

    # CLI approval subcommand
    approval_cmd = subparsers.add_parser("approval", help="Request approval on Apple Watch / iPhone")
    approval_cmd.add_argument("--session-id", required=True, help="Task or session ID")
    approval_cmd.add_argument("--agent", default="Agent", help="Agent display name")
    approval_cmd.add_argument("--action", required=True, help="Action description")
    approval_cmd.add_argument("--relay-url", default=DEFAULT_RELAY_URL, help="Relay server URL")

    # Self-test subcommand
    subparsers.add_parser("test", help="Run MCP self-test")

    args = parser.parse_args()

    if args.command == "test":
        run_self_test()
    elif args.command == "notify":
        res = handle_notify_task({
            "session_id": args.session_id,
            "agent_name": args.agent,
            "phase": args.phase,
            "tool_name": args.tool,
            "status_message": args.status,
            "url": args.url,
            "relay_url": args.relay_url
        })
        print(json.dumps(res, indent=2, ensure_ascii=False))
    elif args.command == "approval":
        res = handle_approval_request({
            "session_id": args.session_id,
            "agent_name": args.agent,
            "action_summary": args.action,
            "relay_url": args.relay_url
        })
        print(json.dumps(res, indent=2, ensure_ascii=False))
    else:
        # Default mode: run MCP stdio server
        run_stdio_server()


if __name__ == "__main__":
    main()
