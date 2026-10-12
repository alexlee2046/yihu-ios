# Security / 安全

This is a source-only client for a server you control, not a hosted service. No security-response SLA or physical-device security certification is claimed.

## Reporting a vulnerability

If GitHub offers **Security → Report a vulnerability** for this repository, use that private channel. Otherwise open an issue containing only a minimal, non-sensitive description and ask the maintainer to arrange private follow-up. Do not publish exploit details, tokens, recordings, task text or private server addresses in issues or PRs.

请勿公开密钥、录音、工作台正文或可直接利用的漏洞细节；先通过仓库可用的私密报告入口联系维护者。

## Security boundaries

- Server permissions and HTTPS trust still apply; the app does not bypass workbench authentication.
- Keep APNs/relay credentials on your server. Personal signing keys, provisioning profiles and model artifacts do not belong in this repository.
- Sharing and transcript insertion are not authorization to send. Preserve user review and explicit confirmation.
- Optional notification, relay and pending Radar reply integrations require their own compatible, authorized server setup. Never expose private ledger data publicly.
- Consult the [README limitations](README.md#models-and-limitations), review the exact branch you build, and avoid using real customer data for testing.
