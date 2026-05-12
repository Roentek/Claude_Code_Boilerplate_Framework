@echo off
REM LightRAG Server Startup Script
REM Quick launcher for the LightRAG web server

echo.
echo ========================================
echo   Starting LightRAG Server
echo ========================================
echo.
echo Port: 9621
echo Web UI: http://localhost:9621
echo API Docs: http://localhost:9621/docs
echo.

REM Set UTF-8 encoding to handle Unicode characters
set PYTHONIOENCODING=utf-8

REM Load .env vars into this process so the server picks them up
for /f "usebackq tokens=1,2 delims== eol=#" %%a in (".env") do (
  if not "%%a"=="" if not "%%b"=="" set "%%a=%%b"
)

REM Start the server (uv --env-file also works if uv >= 0.4)
uv run python -m lightrag.api.lightrag_server --port 9621 --working-dir ./rag_storage

pause
