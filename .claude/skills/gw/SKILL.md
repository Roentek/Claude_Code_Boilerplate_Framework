# gw — Google Workspace CLI

CLI-first interface for Gmail, Google Drive, and Google Calendar. Designed for Claude Code agent integration. Uses `--json` flag throughout. Falls back to `google-workspace-mcp` for bulk/batch operations or complex multi-step flows.

Source: https://github.com/googleworkspace/cli

## When to use

- Send/read/reply to Gmail
- List, upload, share Drive files
- List, create, update, delete Calendar events
- Check free/busy availability
- Save email attachments to Drive
- Multi-account Google Workspace

## Auth

```bash
gw auth login                    # OAuth browser flow — one-time per account
gw auth list                     # list registered accounts
gw auth status                   # show active account
gw auth switch user@example.com  # switch active account
gw auth remove user@example.com  # remove account
```

## Gmail

```bash
gw mail list --json                          # list recent messages
gw mail list --json --query "from:boss"     # search messages
gw mail read <message-id> --json            # read a message (no mark-read)
gw mail send --to user@example.com --subject "Subject" --body "Body"
gw mail reply <message-id> --body "Reply"
gw mail label <message-id> --add STARRED
gw mail mark <message-id> --read
gw mail labels --json                        # list all labels
gw mail attachments <message-id> --json     # list attachments
gw mail download <message-id> <attachment-id> --output ./file.pdf
gw mail to-drive <message-id> <attachment-id>  # save attachment to Drive
```

## Drive

```bash
gw drive list --json                         # list files
gw drive list --json --query "name='report'" # search
gw drive upload ./file.pdf --name "Report"
gw drive create doc --name "New Doc"         # doc/sheet/slide
gw drive share <file-id> --email user@example.com --role reader
gw drive unshare <file-id> --email user@example.com
```

## Calendar

```bash
gw cal list --json                           # list upcoming events
gw cal list --json --days 7                 # next 7 days
gw cal get <event-id> --json
gw cal create --title "Meeting" --start "2026-07-01T10:00" --end "2026-07-01T11:00"
gw cal update <event-id> --title "Updated"
gw cal delete <event-id>
gw cal free --start "2026-07-01" --end "2026-07-02" --json  # free/busy check
```

## Multi-account

```bash
# Per-command account override
gw --account work@company.com mail list --json
gw --account personal@gmail.com cal list --json
```

## MCP fallback (google-workspace-mcp)

Use `google-workspace-mcp` tools when:
- Bulk operations across many files/messages
- Complex Docs/Sheets/Slides editing (batch_update_doc, modify_sheet_values)
- Forms, Tasks, Contacts, Chat — not covered by `gw` CLI
- Multi-step workflows needing in-session state

## Config

```bash
gw config show     # show current config
gw config set key value
```
