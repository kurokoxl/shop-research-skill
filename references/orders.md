# Agent orders

Copy an order, fill the `<…>` slots, and give it to the executor. Every order starts with the common rules.

## Common rules (prepend to every order)
- Today is <date>. Market: <country>. Currency: <EGP>.
- Read-only browsing: no sign-in, cart, checkout or forms other than search and filters. Decline cookie banners if one blocks the page.
- No shell or terminal commands.
- Record only what you saw on a page you opened in this run. **Never invent a price, model code or URL.** If unsure, write UNVERIFIED.
- Prices exactly as shown, in the page currency. Don't convert. Record the struck-through "was" price if shown.
- Browser (for JS sites): built-in browser tools `mcp__Claude_Browser__*` (load with ToolSearch "mcp__Claude_Browser__", max_results 64). Open YOUR OWN tab with `preview_start` (url) and pass that `tabId` to every call; never touch other tabs; close yours at the end.
- **Extract, don't dump (saves most tokens).** Read results pages with ONE `javascript_tool` call that returns compact rows, not `get_page_text`. Use the store's recipe from the registry ("Extractor recipes") if there is one; otherwise start from this and adapt the selector:
  `await new Promise(r=>setTimeout(r,2500)); [...document.querySelectorAll('a[href*="/p/"], a[href*="/product"], a[href*="/dp/"]')].map(a=>a.innerText.replace(/\s+/g,' ').slice(0,160)+' | '+a.href.split('?')[0]).filter(x=>/\d{2},?\d{3}/.test(x)).slice(0,80)`
  For one product page, return only the text around the price: `const t=document.body.innerText; const i=t.search(/sold by|add to cart|EGP|LE/i); t.slice(Math.max(0,i-400), i+300)`.
  Use `get_page_text` only when extraction returns nothing, and always with `max_chars: 4000`. Never take screenshots to read prices.
- When an extractor works on a store that has no recipe yet, put it in your output file under "Recipe: <store>" so it can be saved to the registry.
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
4. Score each priority /10 and give an evidence grade: A measured, B some reviews, C official specs only.
- Spec values must come from measured reviews or the brand's official spec sheet, each with its URL. Store listings and comparison sites are NOT valid sources for specs. If no valid source has a value, write "not confirmed".
Output: one table (model | key criteria | scores | evidence | lowest price | store) plus one line of sources per model. Mark the best value in each criterion row with 🏆.

## Verify (top picks, one cheap agent)
Goal: confirm the price, stock and seller of these offers on the live store page: <store | model | claimed price | URL>.
- Open each URL in your own browser tab. Read it with one extraction call (the store's recipe from the registry, or the product-page snippet in the common rules).
- If the page redirects to a search or home page, or shows no product, the result is SOFT-404.
- Output: | Store | Model | Price on page | Was | Stock | Seller / warranty | Result (OK / CHANGED / OOS / SOFT-404 / ERR) | Exact text read (max 200 chars) |
- The "exact text" column must be copied from the page, not summarised. That is how the main agent checks your work.
