# Lessons from past runs

One dated line per lesson. Merge duplicates, and delete lines that stop being true.

## Searching
- 2026-10-27: Search by specs and budget, not model names. The spec sweep surfaced models no one had mentioned (e.g. Samsung QN70H at 34,999 on Amazon.eg).
- 2026-10-27: Big Egyptian stores (B.TECH, Raya, Noon, Amazon.eg, Carrefour) return nothing to plain fetch. Use the built-in browser, one tab per agent.
- 2026-10-27: Store filters work best: B.TECH "Screen Size", Raya filter + "Load More", Noon URL param `f[tv_screen_size][]=…` + sort by price, Amazon.eg price/size facets.
- 2026-10-27: For "best picture", don't drop smaller sizes: 55" OLEDs (44–46k) beat every 65" Mini LED under 50k.
- 2026-10-27: Search-engine results can show prices from stores that block bots. Use them as leads, then confirm on the store page.

## Verifying
- 2026-10-27: Agents invent plausible URLs, and even "repair" dead links with new invented ones. Always run check-links; drop 404 prices.
- 2026-10-27: Comparison sites (Pricena, Egprices) show stale or dead offers (e.g. a TCL C6K "32,799" that 404'd). Use them only as leads.
- 2026-10-27: Official spec pages can be empty (LG Egypt for 2026 models), and brand support may only paste marketing text. Ask for the internal spec sheet; it gave Dolby Vision, sound watts and the HDMI count.
- 2026-10-27: A brand saying "IPS and VA perform the same" is false. Native contrast is a panel property.

## Executors
- 2026-10-27: Headless Gemini (agy) aborts on any shell command. Repeat the ban in the prompt itself. Its quota can run out mid-run (about 2h reset).
- 2026-10-27: Gemini (agy) store sweeps invent product URLs and prices (most of 66 links dead or soft-404). Use agy only for review research; give ALL store sweeps to browser agents.
- 2026-10-28: Gemini price grids are fine as leads (it found the real Raya QN85D 39,999 deal), but ~60% of its URLs were 404 or redirected (B.TECH, Cairo Sales). Verify every cell you report.
- 2026-10-27: Haiku agents work well for browsing and listing, but sometimes end without a report; read their output file directly.
- 2026-11-01: Token test (Haiku, Noon, 3 pages): full-page reads ~20k tokens per page; JS extraction ~31–34k per page. Fixed per-call context dominates, so extraction mostly improves data (140 clean rows vs 105 plus 15 cut-off prices), not tokens. Real savings come from running fewer agents and calls: model cache, fresh-sweep reuse, one verifier.
