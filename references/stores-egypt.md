# Store registry: Egypt

Add new stores at the end of the right table after each run. Tags: **TV** TVs and screens, **AP** large appliances (fridge, washer, AC, cooker), **SA** small appliances, **PH** phones and tablets, **PC** laptops and computers, **FU** furniture and home. Notes: `JS` needs the built-in browser; `BOT` blocks scripts (403/429), so confirm by phone; `⚠` trust flag.

Last full TV sweep: 2026-10-27 (65"+ and 55"–64").

## Big chains and marketplaces (check first)
| Store | URL | Tags | Notes |
|---|---|---|---|
| B.TECH | https://btech.com/en (TVs: /en/c/tvs-projectors) | TV AP SA PH PC | JS. Has Screen Size filter. Old /en/catalogsearch URLs 404. Hosts 3rd-party sellers on product pages (e.g. "Go Shop", 30-day warranty): check "Sold by" + warranty |
| Raya Shop | https://www.rayashop.com/en | TV AP SA PH PC | JS. Filter + "Load More". Mislabels some products (e.g. QLED as OLED) |
| 2B | https://2b.com.eg/en | TV AP SA PH PC | Works with fetch. Missing product URLs redirect to an empty search with HTTP 200 (soft 404): check-links misses them, open the page |
| Noon Egypt | https://www.noon.com/egypt-en | all | JS, BOT. Size filter via URL param f[tv_screen_size][]=60_69_inches. Many 3rd-party sellers |
| Amazon Egypt | https://www.amazon.eg | all | JS. Use &language=en_AE. Note "sold by Amazon" vs 3rd-party (e.g. Future-Tech, fulfilled by Amazon: ask about warranty). Read the text around "Sold by" |
| Jumia Egypt | https://www.jumia.com.eg | all | JS, BOT. Cloudflare check blocked even the built-in browser (2026-10-27) |
| Carrefour Egypt | https://www.carrefouregypt.com/mafegy/en | TV AP SA PH FU | JS |
| CairoCart | https://cairocart.com | TV AP SA | Redirects (307) |
| Raneen | https://www.raneen.com/en | TV AP SA FU | Search: /en/catalogsearch/result/?q=… works |
| Elaraby Group | https://www.elarabygroup.com/en | TV AP SA | Brand/distributor (Toshiba, Sharp, KAJITO). Product URLs change often (404s) |
| Cairo Sales | https://cairosales.com/en | TV AP SA | BOT (403): confirm prices by phone |
| Elghazawy | https://elghazawy.com | TV AP SA | Product URLs: /ar/product/<id>/. Site search /ar/search?q=… returns unrelated items; agent-reported product IDs 404'd |

## Electronics and appliance chains
| Store | URL | Tags | Notes |
|---|---|---|---|
| Dream 2000 | https://dream2000.com | TV AP PH PC | Search: /search?q=… works. Old /collections/all-tv 404 |
| Rizkalla (Riz) | https://riz.shop | TV AP | Rate-limits after ~4 pages |
| Ehab Center | https://ehabcenter.com | TV AP | Product grid needs JS. Size categories work (TVs 55 Inch etc.) |
| Sharaf DG Egypt | https://egypt.sharafdg.com | TV PH PC | Category URL 404'd once |
| Hyperone | https://www.hyperone.com.eg | TV AP SA FU | BOT |
| Spinneys Egypt | https://spinneys-egypt.com | TV SA | Weak TV range |
| Aman Stores | https://www.amanstores.com | TV AP | Instalment store |
| Dubai Phone | https://www.dubaiphone.net | TV PH PC | Category: /category/tvs. No TCL. BOT on fetch |
| Shaheen Center | https://shaheeneg.com | TV AP | Shows cash-offer prices |
| Kimo Store | https://kimostore.net | TV | |
| Kaza Stores | https://kaza.com.eg | TV AP | |
| Gaballah Stores | https://gaballah.com | TV AP | Some title/slug mismatches |
| Radio Talaat | https://radiotalaat.com | TV AP | Host was down 2026-10 |
| Radio Shack Egypt | https://www.radioshack.com.eg | TV | Old stock |
| Almorshedy Marts | https://almorshedymarts.net | TV AP SA | ⚠ Footer loads a script from a raw IP (http://108.165.20.91:8910/x.js). Buy in store, not online |
| XPRS | https://myxprs.com | TV PH PC | Shopify, Giza showrooms, BNPL |
| Fresh Electric | https://fresh.com.eg | TV AP SA | Brand store |
| Unionaire | https://unionaire.com | TV AP | Brand store |
| Tornado / El Araby brands | via Elaraby | AP | |
| CompuMarts | (from Egprices) | PC TV | Not checked yet |
| Trademark | (from Egprices) | PC | Not checked yet |
| Egypt Laptop | (from Egprices) | PC | Not checked yet |
| Technology Valley | https://tv-it.com | PC TV | Not checked yet |

## Brand stores (own brand only; often no price or empty specs)
| Store | URL | Tags | Notes |
|---|---|---|---|
| Samsung Egypt | https://www.samsung.com/eg | TV AP PH | |
| LG Egypt | https://www.lg.com/eg_en | TV AP | Spec tab can be empty for new models; ask support for the internal sheet |
| TCL Egypt | https://www.tcl.com/eg/en | TV AP | Catalog, few prices |
| Haier Egypt | https://www.haier.com/eg | TV AP | Catalog only |
| Mi Store Egypt | https://mistore-eg.com | PH TV SA | Page came back empty once |

## Telecom shops, BNPL marketplaces, comparison sites
| Store | URL | Tags | Notes |
|---|---|---|---|
| Orange Egypt eShop | https://shop.orange.eg | TV PH | Fetch failed once |
| Vodafone Egypt eShop | https://eshop.vodafone.com.eg | TV PH | Good stock signals |
| Halan Shop | https://shop.halan.com | all | BNPL marketplace; each seller unverified |
| Homzmart | https://homzmart.com | FU TV | Furniture-first |
| Pricena Egypt | https://eg.pricena.com | comparison | Product links often 404, prices stale. Use for leads only |
| Egprices | https://egprices.com | comparison | Same caution |

## Excluded / unsafe
| Site | Reason |
|---|---|
| nilestack.duckdns.org | ⚠ Dynamic-DNS domain, no company or contact info |
| Circuits, Mobile Masr | No TVs (Circuits: PC/tablets; Mobile Masr: phones) |
| Dubizzle / OLX | Used goods: only if the user asks |

## Extractor recipes (tested; one JS call per page via `javascript_tool`)
| Store | Recipe |
|---|---|
| Noon (search) | URL `/egypt-en/search/?q=<words>`. Wait ~3.5 s, then `[...document.querySelectorAll('a[href*="/p/"]')].map(a=>a.innerText.replace(/\n+/g,' / ').slice(0,170))` gives title, rating, price, was price and delivery per card (tested 2026-10-28) |
| Amazon.eg (product) | Add `?language=en_AE`. `const t=document.body.innerText; const i=t.indexOf('Sold by'); t.slice(i-350,i+60)` gives price, stock ("Only N left"), "Fulfilled by" and seller (tested 2026-10-27) |
| Raya (product) | `const t=document.body.innerText; t.slice(t.indexOf('<MODEL CODE>'), t.indexOf('<MODEL CODE>')+500)` gives price, was price, instalments and warranty. A missing product shows an empty page titled "Raya Shop" (soft 404) |
| B.TECH (product) | `t.slice(t.indexOf('Add to cart')-700, t.indexOf('Add to cart'))` gives sizes, warranty, "Sold by" and other sellers' prices (in "LE"). The page also says "out of stock" or "notify me" when unavailable |
| 2B | Missing product URLs redirect to `/catalogsearch/result/?q=…` with HTTP 200: treat that as not found |
| Ehab Center | Use the size category pages (e.g. TVs 55 Inch). Product pages don't show the price in the standard WooCommerce selectors, so read the price from the category card |
