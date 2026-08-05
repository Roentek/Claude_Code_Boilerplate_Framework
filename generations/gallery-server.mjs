import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PORT = 3737;

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".webp": "image/webp",
  ".gif": "image/gif",
  ".mp4": "video/mp4",
  ".webm": "video/webm",
  ".mov": "video/quicktime",
};

const MEDIA_EXT = new Set([".png", ".jpg", ".jpeg", ".webp", ".gif", ".mp4", ".webm", ".mov"]);

function listMedia() {
  const entries = fs.readdirSync(__dirname, { withFileTypes: true });
  const items = [];
  for (const entry of entries) {
    if (!entry.isFile()) continue;
    const ext = path.extname(entry.name).toLowerCase();
    if (!MEDIA_EXT.has(ext)) continue;
    const full = path.join(__dirname, entry.name);
    const stat = fs.statSync(full);
    const sidecarPath = path.join(__dirname, entry.name.replace(ext, "") + ".json");
    let meta = null;
    if (fs.existsSync(sidecarPath)) {
      try {
        meta = JSON.parse(fs.readFileSync(sidecarPath, "utf-8"));
      } catch {
        meta = null;
      }
    }
    items.push({
      file: entry.name,
      type: ext === ".mp4" || ext === ".webm" || ext === ".mov" ? "video" : "image",
      mtime: stat.mtimeMs,
      meta,
    });
  }
  items.sort((a, b) => b.mtime - a.mtime);
  return items;
}

http
  .createServer((req, res) => {
    const url = req.url.split("?")[0];

    if (url === "/api/media") {
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(JSON.stringify(listMedia()));
      return;
    }

    if (url === "/api/styles") {
      const stylesPath = path.join(__dirname, "styles.json");
      fs.readFile(stylesPath, (err, data) => {
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(err ? "[]" : data);
      });
      return;
    }

    const filePath = url === "/" ? "/gallery.html" : url;
    const fullPath = path.join(__dirname, filePath);
    if (!fullPath.startsWith(__dirname)) {
      res.writeHead(403);
      res.end("Forbidden");
      return;
    }
    fs.readFile(fullPath, (err, data) => {
      if (err) {
        res.writeHead(404);
        res.end("Not found");
        return;
      }
      const ext = path.extname(fullPath);
      res.writeHead(200, { "Content-Type": MIME[ext] || "application/octet-stream" });
      res.end(data);
    });
  })
  .listen(PORT, () => {
    console.log(`Generate gallery: http://localhost:${PORT}`);
  });
