# Master 95% of Claude Code (as a Beginner)

> Source: AI Automation Society — By Nate Herk

This guide summarizes the key concepts, the WAT framework, and the steps for building, testing, and deploying AI automations using Claude Code.

---

## 1. Interface & Setup

Claude Code allows you to build complex coding projects and automations inside your local development environment (IDE).

- **The Environment:** Visual Studio Code (VS Code)
- **The Extension:** Search for and install the "Claude Code" extension in the VS Code marketplace
- **Access Requirements:** Requires a paid Anthropic plan (Claude Pro or Team). Sign in with your Anthropic account within the extension.
- **Layout:**
  - **Left Side (Explorer):** File structure — Workflows, Tools, Prompts
  - **Right Side (Agent):** Chat interface for planning and executing tasks
- **Bypass Permissions:** Enable in extension settings for faster builds — allows the agent to edit files without approval on every step

---

## 2. The WAT Framework

A three-layer structure that separates probabilistic reasoning (AI) from deterministic execution (Code).

### Layer 1: Workflows (`/workflows`)

- **Format:** `.md` (Markdown) files
- **Purpose:** SOPs (Standard Operating Procedures) — define the objective, required inputs, tool sequences, and edge case handling in plain English
- **Analogy:** The "manager" telling the worker exactly what steps to take

### Layer 2: Agent (`claude.md`)

- **Format:** `.md` system prompt
- **Purpose:** Core instruction set for Claude Code — tells the agent how to navigate folders, which tools to use, and how to follow the WAT framework
- **Self-Healing:** The agent is instructed to read errors, refactor tools, and update workflows if a process fails

### Layer 3: Tools (`/tools`)

- **Format:** `.py` (Python) files
- **Purpose:** Actual code that executes actions (scraping, emailing, database queries)
- **Security:** API keys and secrets are **never** stored in these files — they live in `.env`

---

## 3. Planning & Building the Automation

Before writing a single line of code, move into **Plan Mode** in the Claude Code interface.

1. **The Brain Dump:** Describe your goal clearly (e.g., "Scrape YouTube channels in the AI niche and create a branded slide deck")
2. **Iterative Questioning:** In Plan Mode, the agent asks clarifying questions about frequency, data points, and delivery methods
3. **To-Do List:** Once the plan is accepted, the agent creates a checklist and executes it step-by-step (creating folders, writing Python scripts, setting up workflows)

---

## 4. Superpowers: MCPs & Skills

Claude Code can be extended with external capabilities to handle tasks it can't do natively.

- **MCP (Model Context Protocol) Servers:** An "App Store" for AI. Provides a universal port to connect to services like Gmail, Google Calendar, or Slack without writing individual API integrations.
- **Skills:** Dynamic, reusable instructions or custom prompts that Claude loads only when needed.
  - **Local Skills:** Installed for a specific project
  - **Global Skills:** Installed across your entire Claude Code instance for use in any project

### Skills vs. Projects

Projects provide static background knowledge always loaded when you start chats within them. Skills provide specialized procedures that activate dynamically when needed and work everywhere across Claude.

### Skills vs. MCP

MCP connects Claude to external services and data sources. Skills provide procedural knowledge — instructions for how to complete specific tasks or workflows. Use both together: MCP connections give Claude access to tools, while Skills teach Claude how to use those tools effectively.

---

## 5. Testing & Optimization

Building the automation is only half the battle — you must test and refine the logic.

- **Initial Run:** Execute the workflow in a test environment to identify missing dependencies or API errors
- **Error Resolution:** If a tool fails, copy the terminal error and paste it back into the Claude Code chat. The agent will analyze the log, fix the Python script, and re-run the test.
- **Branding & Assets:** Drag and drop assets (logos, images) into your project folder and instruct the agent to incorporate them into final deliverables (PDFs, slide decks, etc.)

---

## 6. Deploying to Production (Modal)

Once the automation works locally, host it in the cloud to run automatically on a schedule (Cron) or via a trigger (Webhook).

- **Hosting Platform:** Modal — serverless infrastructure for Python
- **Benefits:** Pay only for the seconds the code is actually running
- **Deployment Steps:**
  1. Install the Modal client via Claude Code
  2. Instruct the agent: "Push this workflow to Modal to run every Monday at 6 AM"
  3. **Security Review:** Always ask the agent to perform a security review before deploying to ensure no API keys or vulnerabilities are exposed
- **Monitoring:** Use the Modal dashboard to check logs and track execution history. If a cloud run fails, paste the Modal logs back into Claude Code to fix the deployment.
