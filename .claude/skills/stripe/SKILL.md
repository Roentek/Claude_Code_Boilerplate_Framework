# /stripe — Stripe CLI + MCP

CLI-first access to Stripe for payments, webhooks, customers, subscriptions, and local dev testing.

## Priority

1. `stripe` CLI (primary — zero token overhead, direct output)
2. `stripe-mcp` MCP (fallback — structured in-session queries, chaining tool calls)

## Auth (one-time)

```bash
stripe login          # browser OAuth — links CLI to your Stripe account
stripe whoami         # verify: shows account email + mode (test/live)
```

For MCP: add `STRIPE_SECRET_KEY` to `.claude/settings.local.json` env block.

## CLI Commands

### Webhooks (most common dev task)

```bash
stripe listen                                      # forward all events to localhost
stripe listen --forward-to localhost:3000/webhook  # forward to specific endpoint
stripe listen --events payment_intent.succeeded    # filter specific events
stripe trigger payment_intent.succeeded            # fire a test event
stripe trigger checkout.session.completed
```

### Logs + events

```bash
stripe logs tail                    # live API request stream
stripe events list                  # recent events
stripe events retrieve evt_xxx      # inspect specific event
```

### Resources (list/get/create)

```bash
stripe customers list
stripe customers retrieve cus_xxx
stripe charges list --limit 10
stripe payment_intents list
stripe payment_intents retrieve pi_xxx
stripe subscriptions list
stripe subscriptions retrieve sub_xxx
stripe products list
stripe prices list
stripe invoices list
```

### Balance + payouts

```bash
stripe balance
stripe payouts list
```

### Test mode vs live mode

```bash
stripe --api-key sk_test_xxx customers list   # explicit key override
# Default: uses key from `stripe login` or STRIPE_SECRET_KEY env var
# Test keys start with sk_test_; live keys with sk_live_
```

### Fixtures (repeatable test data)

```bash
stripe fixtures path/to/fixture.json   # run a fixture file
```

## MCP Fallback (stripe-mcp)

Use `stripe-mcp` when you need structured results chained into other MCP tool calls, or when processing responses programmatically.

Tools available via `stripe-mcp`:
- `create_payment_intent`, `retrieve_payment_intent`, `list_payment_intents`
- `create_customer`, `retrieve_customer`, `update_customer`, `list_customers`
- `create_subscription`, `retrieve_subscription`, `cancel_subscription`, `list_subscriptions`
- `create_product`, `list_products`
- `create_price`, `list_prices`
- `list_invoices`, `retrieve_invoice`
- `list_events`, `retrieve_event`
- `retrieve_balance`

## Webhook Local Dev Pattern

```bash
# Terminal 1: start your app
npm run dev

# Terminal 2: forward Stripe events to local endpoint
stripe listen --forward-to localhost:3000/api/webhooks/stripe

# Terminal 3: trigger test events
stripe trigger payment_intent.succeeded
stripe trigger customer.subscription.created
```

The `stripe listen` command outputs a webhook signing secret (`whsec_xxx`) — use it as `STRIPE_WEBHOOK_SECRET` in your app.

## Key Environment Variables

```bash
STRIPE_SECRET_KEY=sk_test_xxx      # test key; sk_live_xxx for production
STRIPE_PUBLISHABLE_KEY=pk_test_xxx # frontend (public, safe to expose)
STRIPE_WEBHOOK_SECRET=whsec_xxx    # from `stripe listen` output or dashboard
```

## Decision: CLI vs MCP

| Task | Use |
|------|-----|
| Webhook dev loop (`listen` + `trigger`) | CLI only |
| Quick resource lookup | CLI |
| Chaining results into n8n/Trigger.dev | MCP |
| Creating test data programmatically | MCP |
| Live API request stream | CLI (`stripe logs tail`) |
