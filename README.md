# shop-research: a Claude Code skill for buying things

Ask Claude "best TV under 50k" or "cheapest price for TCL 65C6K". The skill then:

1. **Finds every store** in your market that sells the category, and keeps a growing store registry.
2. **Searches all of them** by specs, not model names, with a coverage grid so no store is skipped.
3. **Checks quality from measured reviews** (RTINGS and others), not store labels. Labels like "Mini LED", "OLED" and "144Hz" are often wrong.
4. **Checks every price link** before recommending anything, then gives a one-screen answer.

It works for any product: TVs, fridges, washers, ACs, phones, laptops, furniture.

## Install

Copy the folder into your Claude Code skills folder:

```bash
git clone https://github.com/<owner>/shop-research-skill ~/.claude/skills/shop-research
```

On Windows the folder is `C:\Users\<you>\.claude\skills\shop-research`. Restart Claude Code, then type `/shop-research` or just ask a shopping question.

## First run

The skill asks four questions and saves your answers in `references/profile.md` (kept out of git):
- home market and currency
- report style (one screen or detailed)
- which executors you have (Claude subagents, optionally Gemini via the `agy` CLI)
- brands or stores to always avoid or prefer

Say "reset my profile" to change them.

## What's inside

| File | What it does |
|---|---|
| `SKILL.md` | The steps: profile → request → store discovery → sweep → quality check → link check → report → self-update |
| `references/stores-egypt.md` | Store registry for Egypt (40+ stores, with notes like "needs JS" and "blocks bots"). Other markets get their own file on first use |
| `references/categories.md` | What to check per category, and the misleading labels seen so far |
| `references/orders.md` | Ready-made orders for the search agents |
| `references/lessons.md` | What past runs learned about searching |
| `scripts/check-links.ps1` | Finds dead price links (PowerShell) |

## Notes

- Big JS stores need Claude Code's built-in browser (desktop app). Without it, those stores are marked `ERR`.
- The skill updates its own registry, categories and lessons after every run. Your copy gets better as you use it.
- Prices change daily. The skill always says which prices it confirmed on the store page and which you should confirm by phone.
