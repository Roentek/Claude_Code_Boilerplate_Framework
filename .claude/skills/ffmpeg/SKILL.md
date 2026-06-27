# /ffmpeg — Video & Audio Processing

Programmatic ffmpeg wrapper at `tools/ffmpeg.js`. Use for video/audio manipulation in workflows and automations.

**Requires:** `ffmpeg` system binary (`bash .claude/hooks/install/sys-ffmpeg.sh` or `winget install Gyan.FFmpeg`)

---

## Commands

```bash
# Inspect metadata (duration, codec, resolution, fps, bitrate)
node tools/ffmpeg.js probe <input>

# Re-encode video (default: mp4, CRF 23)
node tools/ffmpeg.js transcode input.avi [output.mp4] [--format mp4|webm|mov] [--quality <crf>] [--resolution 1280x720] [--fps 30]

# Cut a segment (stream-copy — instant, no re-encode)
node tools/ffmpeg.js trim input.mp4 [output.mp4] [--start 00:00:30] [--end 00:01:00] [--duration 30]

# Extract a single frame as JPEG
node tools/ffmpeg.js thumbnail input.mp4 [output.jpg] [--at 00:00:10] [--width 640]

# Rip audio track
node tools/ffmpeg.js extract-audio input.mp4 [output.mp3] [--format mp3|wav|aac|flac] [--bitrate 192]

# Join multiple files (stream-copy — all inputs must share codec/resolution)
node tools/ffmpeg.js concat a.mp4 b.mp4 c.mp4 [--output merged.mp4]
```

All commands output JSON to stdout. Errors go to stderr with exit code 1.

---

## When to Use

| Task | Tool |
|------|------|
| Understand / analyze video content | `/watch` (claude-video) |
| Compress, trim, extract audio, generate thumbnail | `node tools/ffmpeg.js` |
| Download from YouTube / TikTok | `yt-dlp` (used by claude-video) |
| Large-scale batch video scraping | Apify (`/apify-ultimate-scraper`) |

---

## Common Patterns

```bash
# Compress for upload (reduce file size)
node tools/ffmpeg.js transcode big.mp4 small.mp4 --quality 28 --resolution 1280x720

# Thumbnail for a video at 5-second mark
node tools/ffmpeg.js thumbnail video.mp4 thumb.jpg --at 00:00:05 --width 1280

# Extract audio for transcription
node tools/ffmpeg.js extract-audio interview.mp4 interview.mp3 --bitrate 128

# Trim highlights reel
node tools/ffmpeg.js trim raw.mp4 highlight.mp4 --start 00:02:15 --end 00:04:30

# Probe before processing (check codec/resolution/duration)
node tools/ffmpeg.js probe input.mp4
```

---

## In Trigger.dev Automations

```typescript
import { execSync } from 'child_process';

const result = JSON.parse(
  execSync(`node tools/ffmpeg.js thumbnail ${inputPath} ${thumbPath} --at 00:00:05`).toString()
);
if (!result.success) throw new Error(result.error);
```

---

## Time Format

Both `HH:MM:SS` and plain seconds work:
- `--start 00:01:30` = `--start 90`
- `--end 00:02:00` = `--end 120`
