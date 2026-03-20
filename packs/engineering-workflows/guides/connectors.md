# Connectors

## How connector placeholders work

The bundled skills use connector categories rather than forcing one vendor.

Examples:

- `source control`
- `project tracker`
- `monitoring`
- `incident management`
- `chat`
- `knowledge base`
- `CI/CD`

Treat those categories as whichever trusted MCP servers you have connected for
that capability.

## Example mapping from the source plugin

| Category | Example services |
|---|---|
| Chat | Slack, Teams |
| Source control | GitHub, GitLab, Bitbucket |
| Project tracker | Linear, Jira, Asana, Shortcut |
| Knowledge base | Notion, Confluence, Guru, Coda |
| Monitoring | Datadog, New Relic, Grafana, Splunk |
| Incident management | PagerDuty, Opsgenie, Incident.io |
| CI/CD | GitHub Actions, CircleCI, Jenkins, Buildkite |

## Important note

This pack ships only `.cursor/mcp.example.json`. Review and adapt it before
copying anything into a live `mcp.json`.
