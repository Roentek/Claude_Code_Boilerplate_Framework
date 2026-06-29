# Vercel Skill

Deploy, preview, and manage Vercel projects via CLI (primary) or `vercel-mcp` (fallback).

## Setup

```bash
npm install -g vercel   # one-time install (done by setup.sh)
vercel login            # browser OAuth — one-time per machine
vercel link             # link current directory to a Vercel project
```

## CLI Commands (primary — zero MCP tokens)

### Deploy
```bash
vercel                          # deploy current dir (creates preview)
vercel deploy                   # same as above
vercel deploy --prod            # promote to production
vercel build                    # build locally without deploying
vercel promote <url-or-id>      # promote an existing deployment to production
```

### Projects & Deployments
```bash
vercel ls                       # list recent deployments
vercel ls <project>             # list deployments for a project
vercel inspect <url-or-id>      # inspect deployment metadata
vercel rm <url-or-id>           # remove a deployment
vercel link                     # link cwd to a Vercel project
vercel pull                     # pull env vars + project config locally
```

### Environment Variables
```bash
vercel env ls                              # list env vars
vercel env add <name> <env>               # add var (env: production|preview|development)
vercel env rm <name> <env>                # remove var
vercel env pull .env.local                # pull all vars to .env.local
```

### Domains
```bash
vercel domains ls               # list domains
vercel domains add <domain>     # add a domain
vercel domains rm <domain>      # remove a domain
```

### Local Dev
```bash
vercel dev                      # run Vercel dev server locally (port 3000)
```

### Logs
```bash
vercel logs <url-or-id>         # stream logs from a deployment
```

## MCP Fallback (vercel-mcp)

Use `vercel-mcp` when you need structured in-session results or multi-step operations that benefit from persisted tool state. Requires `VERCEL_TOKEN` in `.claude/settings.local.json`.

Get token: https://vercel.com/account/tokens

## Decision Matrix

| Task | Use |
|------|-----|
| Deploy, inspect, manage env vars | `vercel` CLI |
| List projects / deployments | `vercel ls` CLI |
| Structured results for agentic pipelines | `vercel-mcp` |
| Bulk operations across many projects | `vercel-mcp` |
