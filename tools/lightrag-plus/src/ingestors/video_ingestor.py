import logging
from pathlib import Path

logger = logging.getLogger(__name__)

_CV2_AVAILABLE = False
try:
    import cv2
    _CV2_AVAILABLE = True
except ImportError:
    pass


class VideoIngestor:
    DEFAULT_INTERVAL_SECONDS = 5

    def extract_keyframes(
        self, source: str | Path, interval_seconds: int = DEFAULT_INTERVAL_SECONDS
    ) -> list[bytes]:
        """Extract keyframes at regular intervals. Returns list of JPEG bytes.

        Requires opencv-python: pip install opencv-python-headless
        """
        if not _CV2_AVAILABLE:
            logger.warning(
                "opencv-python not installed — video keyframe extraction unavailable. "
                "Install with: pip install opencv-python-headless"
            )
            return []

        cap = cv2.VideoCapture(str(source))
        fps = cap.get(cv2.CAP_PROP_FPS) or 30
        frame_interval = max(1, int(fps * interval_seconds))
        frames = []
        frame_idx = 0

        try:
            while True:
                ret, frame = cap.read()
                if not ret:
                    break
                if frame_idx % frame_interval == 0:
                    ok, buf = cv2.imencode(".jpg", frame)
                    if ok:
                        frames.append(bytes(buf))
                frame_idx += 1
        finally:
            cap.release()

        return frames
