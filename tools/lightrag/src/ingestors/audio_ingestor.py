from pathlib import Path

_MIME_MAP = {
    ".mp3": "audio/mpeg",
    ".wav": "audio/wav",
    ".ogg": "audio/ogg",
    ".m4a": "audio/mp4",
    ".aac": "audio/aac",
    ".flac": "audio/flac",
}


class AudioIngestor:
    def process(self, source: str | Path) -> tuple[bytes, str]:
        """Read audio file. Returns (bytes, mime_type)."""
        path = Path(source)
        mime = _MIME_MAP.get(path.suffix.lower(), "audio/mpeg")
        return path.read_bytes(), mime
