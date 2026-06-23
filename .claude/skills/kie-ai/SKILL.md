# /kie-ai

Kie.ai media generation — images, video, music, speech via 20+ AI models.

## Priority: CLI first, MCP fallback

| Situation | Use |
|-----------|-----|
| Default | `kie-cli` — zero context tokens, same API |
| MCP unavailable / startup error | `kie-cli` automatically |
| Need structured in-session result piped to another MCP tool | `mcp__kie-ai__*` |

**Auto-switch rule:** If an MCP tool call fails or MCP server is not connected, immediately rerun as `kie-cli <tool_name> <args> --json` with the same parameters.

## CLI Usage

```bash
# Requires KIE_AI_API_KEY in environment
export KIE_AI_API_KEY="your-key"

# Generate image
kie-cli nano_banana_image --prompt "red panda coding at night, neon" --resolution 2K --json

# Generate video
kie-cli veo3_generate_video --prompt "timelapse of a city at dusk" --json

# Generate music
kie-cli suno_generate_music --prompt "upbeat electronic, energetic" --customMode --model V5 --title "Energy" --json

# Text-to-speech
kie-cli elevenlabs_tts --text "Hello world" --voice Rachel --model turbo --json

# Poll task (async — all generations return task_id first)
kie-cli get_task_status --task_id <id> --json

# List recent tasks
kie-cli list_tasks --json

# Discover all tools
kie-cli --help
kie-cli <tool_name> --help
```

## Available Tools (29 total)

**Image:** `nano_banana_image`, `flux2_image`, `flux_kontext_image`, `bytedance_seedream_image`, `gpt_image_2`, `qwen_image`, `ideogram_reframe`, `recraft_remove_background`, `z_image`, `grok_imagine`

**Video:** `veo3_generate_video`, `kling_video`, `kling_avatar`, `hailuo_video`, `wan_video`, `wan_animate`, `bytedance_seedance_video`, `runway_aleph_video`, `happyhorse_video`, `infinitalk_lip_sync`, `grok_imagine`

**Audio:** `suno_generate_music`, `elevenlabs_tts`, `elevenlabs_ttsfx`

**Utility:** `get_task_status`, `list_tasks`, `wait_for_task`, `topaz_upscale_image`, `midjourney_generate`, `veo3_get_1080p_video`

## Async Pattern

All generations are async — tool returns `task_id`, not the result directly.

```bash
# 1. Submit
RESULT=$(kie-cli nano_banana_image --prompt "sunset over mountains" --json)
TASK_ID=$(echo $RESULT | node -e "process.stdin|require('stream').setEncoding('utf8'),require('stream').resume(),process.stdin.on('data',d=>process.stdout.write(JSON.parse(d).taskId||''))")

# 2. Poll until done
kie-cli get_task_status --task_id $TASK_ID --json
```

## MCP Fallback Commands (when CLI insufficient)

```
mcp__kie-ai__nano_banana_image
mcp__kie-ai__veo3_generate_video
mcp__kie-ai__suno_generate_music
mcp__kie-ai__get_task_status
mcp__kie-ai__list_tasks
mcp__kie-ai__wait_for_task   ← streams progress, auto-resolves URLs
```

## Token Optimization

Limit MCP tools loaded (saves context on every turn):

```json
"KIE_AI_ENABLED_TOOLS": "nano_banana_image,veo3_generate_video,suno_generate_music,elevenlabs_tts,get_task_status,list_tasks"
```

Or by category: `"KIE_AI_TOOL_CATEGORIES": "image"` — loads only image tools + utility.

## Config

| Env var | Value |
|---------|-------|
| `KIE_AI_API_KEY` | From kie.ai dashboard → API Keys |
| `KIE_AI_BASE_URL` | `https://api.kie.ai/api/v1` (default) |
| `KIE_AI_TIMEOUT` | `60000` ms (default) |
