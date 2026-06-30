# Alpaca Trading Skill

Algorithmic trading, market data, and account management via Alpaca.

**Pattern: CLI-first (`alpaca`), then `alpaca` MCP fallback for structured in-session results.**

## When to Use This Skill

- Trade stocks, crypto, or options via command line or automation
- Query live/historical market data (bars, quotes, trades, snapshots)
- Manage positions, orders, watchlists, wallets
- Build Trigger.dev automations that interact with markets
- Paper trading and strategy testing (default mode — no real money)

## Authentication

```bash
# Option A — OAuth (paper trading only)
alpaca profile login

# Option B — API keys (paper + live)
export ALPACA_API_KEY=PKxxx...
export ALPACA_SECRET_KEY=xxx...
export ALPACA_LIVE_TRADE=true   # omit for paper (default)

# Check
alpaca doctor
alpaca account
```

Get free paper keys: alpaca.markets → Paper Trading → API Keys

## CLI-First Commands

```bash
# ── Account ──────────────────────────────────────────────────
alpaca account                         # account info + buying power
alpaca account activities              # recent activity
alpaca portfolio history --period 1M   # portfolio P&L chart data

# ── Orders ───────────────────────────────────────────────────
alpaca order list                      # open orders
alpaca order list --status all         # all orders
alpaca order buy AAPL --qty 1          # market buy 1 share (PAPER by default)
alpaca order sell AAPL --qty 1         # market sell
alpaca order buy AAPL --qty 1 --type limit --limit-price 180
alpaca order cancel --all              # cancel all open orders
alpaca order cancel <order-id>

# ── Positions ────────────────────────────────────────────────
alpaca position list                   # all open positions
alpaca position get AAPL               # single position
alpaca position close AAPL             # close a position
alpaca position close --all            # close everything

# ── Market Data ──────────────────────────────────────────────
alpaca data bars AAPL --timeframe 1Day --start 2024-01-01
alpaca data bars AAPL BTC/USD --timeframe 1Hour --limit 48
alpaca data quote AAPL                 # latest quote
alpaca data trade AAPL                 # latest trade
alpaca data snapshot AAPL MSFT NVDA    # multi-symbol snapshot
alpaca data news --symbols AAPL        # recent news

# ── Screeners ────────────────────────────────────────────────
alpaca data screener movers --type gainers --limit 10
alpaca data screener active --by volume --limit 10

# ── Watchlists ───────────────────────────────────────────────
alpaca watchlist list
alpaca watchlist create MyList
alpaca watchlist add MyList AAPL MSFT

# ── Market Clock / Calendar ──────────────────────────────────
alpaca clock                           # current market status (open/closed)
alpaca calendar --start 2025-01-01 --end 2025-01-31

# ── Output control ───────────────────────────────────────────
alpaca data bars AAPL --output json    # JSON for scripting
alpaca data bars AAPL --output csv     # CSV export
alpaca data bars AAPL | jq '.bars[0]' # pipe to jq
```

## MCP Fallback (alpaca MCP)

Use MCP tools when you need structured, in-session results without spawning a subprocess — e.g., inside an agent workflow or when chaining results across tool calls.

```
# Available MCP tools (read-only by default in settings.local.json.example):
mcp__alpaca__get_account_info
mcp__alpaca__get_all_positions / get_open_position
mcp__alpaca__get_orders / get_order_by_id
mcp__alpaca__get_stock_bars / get_stock_snapshot
mcp__alpaca__get_stock_latest_quote / get_stock_latest_trade
mcp__alpaca__get_crypto_bars / get_crypto_snapshot
mcp__alpaca__get_option_chain / get_option_contracts
mcp__alpaca__get_market_movers / get_most_active_stocks
mcp__alpaca__get_clock / get_calendar
mcp__alpaca__get_watchlists
```

**Note:** The MCP server (`alpaca-mcp-server` via uvx) is read-only by default. For order placement and position management, use the CLI.

## Environment Variables

| Variable | Purpose |
|----------|---------|
| `ALPACA_API_KEY` | API key (PKxxx...) |
| `ALPACA_SECRET_KEY` | Secret key |
| `ALPACA_LIVE_TRADE` | `true` for live; omit for paper (default) |
| `ALPACA_PROFILE` | Named profile to use |
| `ALPACA_OUTPUT` | `json` or `csv` output format |

## Safety

- Default mode is **PAPER trading** — no real money at risk
- Set `ALPACA_LIVE_TRADE=true` explicitly when switching to live
- `alpaca doctor` validates connectivity and auth before running automations
- CLI executes immediately with no confirmation prompts — review orders before running in live mode

## Trigger.dev Integration Example

```typescript
import { task } from "@trigger.dev/sdk/v3";

export const dailyMarketScan = task({
  id: "daily-market-scan",
  run: async () => {
    // Use alpaca CLI via shell for zero-dependency market data
    const { execSync } = require("child_process");
    const movers = JSON.parse(
      execSync("alpaca data screener movers --type gainers --limit 5 --output json").toString()
    );
    return movers;
  },
});
```
