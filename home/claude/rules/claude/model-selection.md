# Model Selection for Subagents (Task-Type Tiering)

The main session (orchestrator) runs on the model configured via
`model` in `settings.json`.

Subagents without an explicit `model` (Explore, Plan, general-purpose,
fork) INHERIT the main-loop model. To keep the main-loop tier reserved
for orchestration and truly hard work, ALWAYS pass `model` explicitly
when spawning subagents (Agent tool `model` param, Workflow `agent()`
opts):

| Task type | Model | Notes |
| --- | --- | --- |
| Ultra-hard investigation | `fable` | ONLY when the user explicitly asks for this tier, or when a lower-tier agent got stuck / made no progress |
| Investigation / research | `opus` | Explore, Plan, general-purpose — codebase exploration, planning, root-cause analysis |
| Implementation | `opus` | code-writer already pins `model: opus` in frontmatter |
| Routine todo-style multi-step tasks | `sonnet` | Summaries, conflict resolution, checklist execution (git-describe / pr-describe / git-resolve) |
| Trivial mechanical tasks | `haiku` | Single-purpose mechanical work (git-rebase) |

Custom agents in `~/.claude/agents/` pin their tier via `model:`
frontmatter — keep new agent definitions consistent with this table.

Enforcement: the built-in-agent case is enforced mechanically by the
`enforce-subagent-model.sh` PreToolUse hook — a built-in subagent
spawned without `model` gets `model: opus` injected. Explicit `model`
values (including fable escalation) pass through untouched. Workflow
`agent()` calls are NOT covered by the hook; follow this table there.

Do NOT force delegation to subagents just to satisfy this tiering.
Delegate when it genuinely helps (broad searches, parallel fan-out,
isolation); serial delegation of small tasks adds latency and loses
conversation context for no benefit.

Escalation is per-task, not sticky: when an agent stalls at its
assigned tier, re-spawn that specific task at the ultra-hard tier from
the table above; do not keep using the escalated model for subsequent
unrelated tasks.
