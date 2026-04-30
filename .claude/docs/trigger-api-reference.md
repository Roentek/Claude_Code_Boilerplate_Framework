# Trigger.dev API Reference

Full code examples for Trigger.dev SDK v4. All tasks use `@trigger.dev/sdk`.

## Basic Task

```ts
import { task } from "@trigger.dev/sdk";

export const processData = task({
  id: "process-data",
  retry: {
    maxAttempts: 3,
    factor: 2,
    minTimeoutInMs: 5000,
    maxTimeoutInMs: 30_000,
  },
  run: async (payload: { userId: string; data: any[] }) => {
    console.log(`Processing ${payload.data.length} items for user ${payload.userId}`);
    return { processed: payload.data.length };
  },
});
```

---

## Scheduled Task (Cron)

```ts
import { schedules } from "@trigger.dev/sdk";

export const dailyReport = schedules.task({
  id: "daily-report",
  cron: "0 9 * * *", // 9am UTC every day

  run: async () => {
    console.log("Running daily report");
    // task logic here
    return { status: "done" };
  },
});
```

Common cron expressions:

- `"*/30 * * * *"` — every 30 minutes
- `"0 * * * *"` — every hour
- `"0 */8 * * *"` — every 8 hours
- `"0 9 * * *"` — 9am daily
- `"0 8 * * 1"` — every Monday at 8am

## Schema Task (with Zod validation)

```ts
import { schemaTask } from "@trigger.dev/sdk";
import { z } from "zod";

export const validatedTask = schemaTask({
  id: "validated-task",
  schema: z.object({
    name: z.string(),
    videoId: z.string(),
    publishedAt: z.string(),
  }),
  run: async (payload) => {
    // payload is fully typed and validated before run() is called
    return { message: `Processing ${payload.name}` };
  },
});
```

## Triggering Tasks from Backend Code

```ts
import { tasks } from "@trigger.dev/sdk";
import type { processData } from "./trigger/tasks.js";

// Single trigger — fire and forget
const handle = await tasks.trigger<typeof processData>("process-data", {
  userId: "123",
  data: [{ id: 1 }, { id: 2 }],
});

// Batch trigger — up to 1,000 items, 3MB per payload
const batchHandle = await tasks.batchTrigger<typeof processData>("process-data", [
  { payload: { userId: "123", data: [{ id: 1 }] } },
  { payload: { userId: "456", data: [{ id: 2 }] } },
]);
```

## Triggering from Inside a Task

```ts
export const parentTask = task({
  id: "parent-task",
  run: async (payload) => {

    // Fire and forget — don't wait for result
    await childTask.trigger({ data: "value" });

    // Trigger and wait — returns a Result object, NOT the raw output
    const result = await childTask.triggerAndWait({ data: "value" });
    if (result.ok) {
      console.log("Output:", result.output); // the return value of childTask.run()
    } else {
      console.error("Failed:", result.error);
    }

    // Unwrap shorthand — throws on failure instead of checking result.ok
    const output = await childTask.triggerAndWait({ data: "value" }).unwrap();

    // Batch trigger and wait
    const results = await childTask.batchTriggerAndWait([
      { payload: { data: "item1" } },
      { payload: { data: "item2" } },
    ]);
    for (const run of results) {
      if (run.ok) console.log("Success:", run.output);
    }
  },
});

export const childTask = task({
  id: "child-task",
  run: async (payload: { data: string }) => {
    return { processed: payload.data };
  },
});
```

> **Never** wrap `triggerAndWait`, `batchTriggerAndWait`, or `wait.*` in `Promise.all` —
> it is not supported and will cause unexpected behavior.

## Idempotency Keys (prevent duplicate processing)

```ts
await processVideo.trigger(
  { videoId: "abc123", title: "My Video" },
  {
    idempotencyKey: `video-abc123`, // same key = same run, no duplicate
  }
);
```

Use idempotency keys whenever the same item could be triggered more than once — e.g., when a scheduled task polls a feed and an item might appear in two consecutive windows.

## Waits

```ts
import { task, wait } from "@trigger.dev/sdk";

export const taskWithWaits = task({
  id: "task-with-waits",
  run: async (payload) => {

    // Wait for a duration
    await wait.for({ seconds: 30 });
    await wait.for({ minutes: 5 });
    await wait.for({ hours: 1 });

    // Wait until a specific date
    await wait.until({ date: new Date("2025-01-01") });

    // Wait for an external signal (e.g., human approval)
    await wait.forToken({
      token: "approval-token",
      timeoutInSeconds: 3600,
    });

    return { status: "completed" };
  },
});
```

> Waits longer than 5 seconds are automatically checkpointed — they do not consume compute time
> while waiting.

## Debounced Triggering

Consolidate multiple rapid triggers into a single execution:

```ts
// Leading mode (default) — executes with the FIRST payload, delays on subsequent triggers
await myTask.trigger(
  { userId: "123" },
  {
    debounce: {
      key: "user-123-update",
      delay: "5s",
    },
  }
);

// Trailing mode — executes with the LAST payload after the delay window
await myTask.trigger(
  { data: "latest-value" },
  {
    debounce: {
      key: "trailing-example",
      delay: "10s",
      mode: "trailing",
    },
  }
);
```

## Retry Configuration

```ts
export const resilientTask = task({
  id: "resilient-task",
  retry: {
    maxAttempts: 10,
    factor: 1.8,          // exponential backoff multiplier
    minTimeoutInMs: 500,
    maxTimeoutInMs: 30_000,
    randomize: false,
  },
  run: async (payload) => {
    // If this throws, Trigger.dev will retry automatically
    return { done: true };
  },
});
```

## Orchestrator + Processor Pattern

The standard pattern for automations that poll for new items and process each one:

```ts
// check-task.ts — runs on a schedule, lightweight
import { schedules } from "@trigger.dev/sdk";
import { processItem } from "./process-item.js"; // note: .js extension required

export const checkTask = schedules.task({
  id: "check-task",
  cron: "0 */8 * * *", // every 8 hours

  run: async () => {
    const items = await fetchNewItems(); // poll your source
    for (const item of items) {
      await processItem.trigger(
        { id: item.id, data: item },
        { idempotencyKey: `item-${item.id}` } // prevent duplicates
      );
    }
    return { dispatched: items.length };
  },
});

// process-item.ts — handles heavy work per item
import { task } from "@trigger.dev/sdk";

export const processItem = task({
  id: "process-item",
  run: async (payload: { id: string; data: any }) => {
    // Do the heavy lifting: LLM calls, API requests, output posting
    return { processed: payload.id };
  },
});
```

## NEVER Use (v2 — breaks everything)

```ts
// ❌ This is Trigger.dev v2 syntax — DO NOT USE
client.defineJob({
  id: "job-id",
  run: async (payload, io) => { /* ... */ },
});
```

Always use `task()`, `schedules.task()`, or `schemaTask()` from `@trigger.dev/sdk`.
