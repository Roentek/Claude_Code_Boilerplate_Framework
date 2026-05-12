import io
from pathlib import Path
from PIL import Image


class ImageIngestor:
    MAX_DIM = 1024
    OUTPUT_MIME = "image/jpeg"

    def process(self, source: str | Path | bytes) -> tuple[bytes, str]:
        """Resize and normalize image. Returns (jpeg_bytes, mime_type)."""
        if isinstance(source, bytes):
            img = Image.open(io.BytesIO(source))
        else:
            img = Image.open(source)

        with img:
            img.thumbnail((self.MAX_DIM, self.MAX_DIM), Image.LANCZOS)
            if img.mode not in ("RGB", "L"):
                img = img.convert("RGB")
            buf = io.BytesIO()
            img.save(buf, format="JPEG", quality=85)
            return buf.getvalue(), self.OUTPUT_MIME
