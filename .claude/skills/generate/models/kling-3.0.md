# Kling 3.0

Cheap tier default for video. General purpose — good motion, fair price.

| Field | Value |
| --- | --- |
| Model ID | `kling-3.0/video` (`std` = 720p, `pro` = 1080p) |
| Provider | Kie AI |
| Method | Async — submit, then poll |
| Type | Video |
| API key | `.env` / `settings.local.json` → `KIE_AI_API_KEY` |
| Cost | $0.20–$0.35/sec ballpark — a 5s clip ≈ $1–1.75. **Always quote before running.** |

## Call

Prefer `kie-cli`. Fall back to `kie-ai` MCP tool `kling_video`.

```bash
kie-cli generate --model kling-3.0 --prompt "..." --duration 5 --quality std --out generations/
```

## Response handling — async

1. Submit → response has a task id.
2. Poll status every 10–15s.
3. On complete, response has a file URL.
4. Download immediately — result URLs often expire in hours.
5. Save flat into `generations/`, then write the sidecar log.

Use `mcp__kie-ai__get_task_status` / `wait_for_task` if polling via MCP instead of CLI.

## Notes

- This is a paid video run — quote model, duration, resolution, and dollar cost, then wait for explicit go-ahead before submitting. One approval = one run.
