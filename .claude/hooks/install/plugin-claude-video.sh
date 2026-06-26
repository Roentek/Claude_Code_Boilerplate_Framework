#!/usr/bin/env bash
# Install claude-video plugin — watch and analyze video with Claude (/watch command)
# Standalone: bash .claude/hooks/install/plugin-claude-video.sh

. "$(dirname "$0")/lib.sh"

echo "  Installing claude-video plugin (watch@claude-video)..."
_install_plugin "watch" "claude-video"

echo ""
echo "  System dependencies required for /watch:"
echo "    ffmpeg  — frame extraction"
echo "    yt-dlp  — download from YouTube, TikTok, Vimeo, 500+ sites"
echo ""
if _is_windows; then
  echo "  Windows install:"
  echo "    winget install ffmpeg"
  echo "    pip install yt-dlp   (or: winget install yt-dlp)"
else
  echo "  macOS:  brew install ffmpeg yt-dlp"
  echo "  Linux:  sudo apt install ffmpeg && pipx install yt-dlp"
fi
echo ""
echo "  Optional transcription API keys (set in ~/.config/watch/.env):"
echo "    GROQ_API_KEY   — Whisper large-v3 (cheaper/faster, recommended)"
echo "    OPENAI_API_KEY — Whisper-1 (fallback)"
echo "  Native captions (most YouTube) work without any key."
