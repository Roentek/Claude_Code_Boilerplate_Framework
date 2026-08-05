# Veo 3.1

Advanced tier for video. Higher quality output from a start frame, slower than Kling. Use for hero shots where Kling's motion isn't good enough.

| Field | Value |
| --- | --- |
| Model ID | `veo-3.1-generate-preview` |
| Provider | Kie AI |
| Method | Async — submit, then poll |
| Type | Video |
| API key | `.env` / `settings.local.json` → `KIE_AI_API_KEY` |
| Cost | Higher than Kling per second — check current Kie AI pricing before quoting. 8s clips, 720p, 1–4 samples/call. **Always quote before running.** |

## Call

Prefer `kie-cli`. Fall back to `kie-ai` MCP tool `veo3_generate_video` (+ `veo3_get_1080p_video` for the upscaled result).

```bash
kie-cli generate --model veo-3.1 --start-frame generations/refs/hero.png --prompt "..." --out generations/
```

## Response handling — async

Same pattern as Kling: submit → task id → poll every 10–15s → download URL immediately on complete (expires in hours) → save flat → write sidecar log.

## Notes

- Advanced/expensive tier — only use after Kling has been tried and the motion/quality isn't sufficient, or the user explicitly asks for it.
- Quote cost and get explicit go-ahead before submitting. One approval = one run.
