# Agent orders

Copy an order, fill the `<…>` slots, and give it to the executor. Every order starts with the common rules.

## Common rules (prepend to every order)
- Today is <date>. Market: <country>. Currency: <EGP>.
- Read-only browsing: no sign-in, cart, checkout or forms other than search and filters. Decline cookie banners if one blocks the page.
- No shell or terminal commands.
- Record only what you saw on a page you opened in this run. **Never invent a price, model code or URL.** If unsure, write UNVERIFIED.
- Prices exactly as shown, in the page currency. Don't convert. Record the struck-through "was" price if shown.
- Browser (for JS sites): built-in browser tools `mcp__Claude_Browser__*` (load with ToolSearch "mcp__Claude_Browser__", max_results 64). Open YOUR OWN tab with `preview_start` (url) and pass that `tabId` to every call; never touch other tabs; close yours at the end. Read with `get_page_text` / `find`.
- Write only your output file: <path>. Reply in under 6 lines.

## Discovery (find stores not in the registry)
Goal: find online stores in <country> that sell <category> and are NOT in <registry path>.
- Search with many queries in English AND <local language>: "buy <category> online <country>", "<category> price <country>", "best store for <category>", brand + "dealer" / "authorized", instalment/BNPL partners (Egypt: valU, Contact, Souhoola, Aman, Sympl, Halan), Facebook/Instagram shops, comparison sites (Egypt: Pricena, Egprices) and the shops they list.
- For each new store: open it, check that it sells <category>, note the category URL, whether it needs JS, and trust signals (address, phone, HTTPS, reviews). Flag anything odd: no contact info, dynamic-DNS domain, odd scripts, prices far below the market.
- Output: | Store | URL | Category URL | Tags | Needs JS? | Trust notes |. Aim for 10+ new stores.

## Spec sweep (best-for-specs mode)
Goal: list EVERY <category> at your stores that matches: <hard limits, e.g. "65 inch or larger">, price ≤ <budget>. Any brand. Search by specs, NOT by model names.
Stores: <list with URLs>.
- Use the store filters (size/capacity/type, price ≤ budget, sort by price). If there are none, use the store search with spec words in both languages.
- Read ALL result pages ("load more" to the end).
- Open the product page for any listing whose title doesn't show the model code or the key specs (<key spec list>).
- Output table: | Store | Brand | Model code | <key spec columns, as listed> | Price | Was | In stock? | Seller (store/3rd-party) | Exact URL |
- Coverage: one line per store, "searched, N listings, pages X of Y, filters used" or "ERR: <what happened>". Every store must have a line.

## Model price grid (lowest-price mode)
Goal: the price of <model> (alternate same-hardware codes: <codes>) at EVERY store below.
- Search each store for each code (the store search, or `site:<domain> <code>`).
- Grid: one row per code, one column per store. Each cell: the price (+ `OOS` if out of stock), `NL` (searched, not listed) or `ERR` (site/search failed). **No empty cells.**
- Then a details table for each priced cell: | Store | Code | Price | Was | Stock | Seller | Warranty stated | Exact URL |.
- Watch out for similar names that are different products.

## Quality check (best-for-specs mode)
Goal: judge these candidates for a buyer whose priorities are: <priorities, in order>.
Candidates: <model + price + store>.
For each model:
1. Find the same-hardware model sold elsewhere (US/UK/EU name) so reviews can be found.
2. Collect the criteria for this category from categories.md (<paste the category section>), measured by reviewers where possible (give URLs).
3. Flag misleading store labels (marketing vs real spec).
4. Score each priority /10 and give an evidence grade: A measured, B some reviews, C specs only.
Output: one table (model | key criteria | scores | evidence | lowest price | store) plus one line of sources per model.
