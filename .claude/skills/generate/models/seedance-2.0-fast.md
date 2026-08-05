# Seedance 2.0 Fast

Advanced tier for video. Reference-to-video — feed up to 9 images and it animates them, instead of working from a text prompt.

| Field | Value |
| --- | --- |
| Model ID | `bytedance/seedance-2.0/fast/reference-to-video` |
| Provider | Kie AI (fal.ai is the documented alternate route, not yet wired) |
| Method | Async — submit, then poll |
| Type | Video |
| API key | `.env` / `settings.local.json` → `KIE_AI_API_KEY` |
| Cost | ~$0.24/sec at 720p — a 5s clip ≈ $1.21. **Always quote before running.** |

## Call

Prefer `kie-cli`. Fall back to `kie-ai` MCP tool `bytedance_seedance_video`.

```bash
kie-cli generate --model seedance-2.0-fast --refs generations/refs/img1.png,generations/refs/img2.png --out generations/
```

## Response handling — async

Same pattern as Kling: submit → task id → poll every 10–15s → download URL immediately on complete (expires in hours) → save flat → write sidecar log.

## Notes

- Use when the request is "animate these reference images," not a text-prompt video — that's Kling/Veo's job.
- Quote cost and get explicit go-ahead before submitting. One approval = one run.
