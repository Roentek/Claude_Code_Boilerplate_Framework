# llmfit

Right-size LLM models to your hardware. Detects GPU/CPU/RAM, scores every model for fit/speed/quality, downloads GGUF weights, runs inference. CLI-first; MCP (`llmfit serve --mcp`) as fallback.

Source: https://github.com/AlexsJones/llmfit

## When to use

- "What LLM can run on my machine?"
- "Compare llama3 vs mistral for my GPU"
- "Download a GGUF model"
- "Recommend a model with tool-use support"
- "Plan hardware upgrade for a specific model"
- "Benchmark my inference setup"

## CLI (Primary — zero context tokens)

```bash
# Hardware detection
llmfit system --json

# Find models that fit your system
llmfit fit --json
llmfit fit --json --tool-use        # only models with function-call support
llmfit fit --json -p                # perfect-fit only (no compromise)
llmfit fit --json -n 10             # top 10

# Recommend top models for your hardware
llmfit recommend --json

# Search for a specific model
llmfit search "llama 3" --json
llmfit info "llama-3.3-70b" --json

# Compare two models side-by-side
llmfit diff "llama-3.3-70b" "mistral-7b" --json

# Plan hardware for a model you want
llmfit plan "llama-3.3-70b" --json

# Download GGUF weights from HuggingFace
llmfit download "model-name"

# Search HuggingFace for GGUF models
llmfit hf-search "llama 3 8b" --json

# Run a downloaded model
llmfit run "model-name"

# Benchmark inference against running providers
llmfit bench --json

# Update model database cache
llmfit update
```

### Global flags

| Flag | Effect |
|------|--------|
| `--json` | Structured JSON output (for agent integration) |
| `--memory <SIZE>` | Override GPU VRAM (e.g. "32G") |
| `--ram <SIZE>` | Override system RAM |
| `--cpu-cores <N>` | Override CPU core count |
| `--max-context N` | Cap context length for memory estimation |

## MCP (Fallback — structured in-session results)

Use when you need to pipe results into other tools or maintain state across calls.

MCP server runs via stdio: `llmfit serve --mcp`

Configured in `.mcp.json` as `llmfit-mcp`. Use `llmfit-mcp` MCP tools when:
- CLI output needs to feed into another MCP tool in the same turn
- You need persistent server state during a session

## REST API (Optional)

```bash
# Start REST API + web dashboard at http://localhost:8787
llmfit serve --port 8787
```

Endpoints documented in API.md inside the llmfit repo.

## Environment variables

| Var | Purpose |
|-----|---------|
| `LOCALMAXXING_API_KEY` | Community benchmark data from localmaxxing.com (optional) |
| `OLLAMA_CONTEXT_LENGTH` | Default context cap when `--max-context` not set |

## Common patterns

```bash
# Find all tool-use capable models that fit exactly, output JSON
llmfit fit --json --tool-use -p

# Evaluate what would fit on a machine with 24GB VRAM
llmfit fit --json --memory 24G

# Download best-fit GGUF and run it
llmfit recommend --json | jq -r '.recommendations[0].name' | xargs llmfit download
```
