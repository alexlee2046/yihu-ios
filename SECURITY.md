# Security / 安全

This is a source-only client for a server you control, not a hosted service. No security-response SLA or physical-device security certification is claimed.

## Reporting a vulnerability

If GitHub offers **Security → Report a vulnerability** for this repository, use that private channel. Otherwise open an issue containing only a minimal, non-sensitive description and ask the maintainer to arrange private follow-up. Do not publish exploit details, tokens, recordings, task text or private server addresses in issues or PRs.

优先通过仓库可用的私密漏洞报告入口联系维护者；若该入口不可用，仅提交最简、不含敏感信息的 Issue，请维护者安排私下跟进。请勿在 Issue 或 PR 中公开漏洞利用细节、密钥、录音、工作台正文或私有服务器地址。

## Security boundaries

- Server permissions and HTTPS trust still apply; the app does not bypass workbench authentication.
- Keep APNs/relay credentials on your server. Personal signing keys, provisioning profiles and model artifacts do not belong in this repository.
- Sharing and transcript insertion are not authorization to send. Preserve user review and explicit confirmation.
- Optional notification, relay and pending Radar reply integrations require their own compatible, authorized server setup. Never expose private ledger data publicly.
- Consult the [README limitations](README.md#models-and-limitations), review the exact branch you build, and avoid using real customer data for testing.
