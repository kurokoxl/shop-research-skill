#!/usr/bin/env bash
set -uo pipefail

dir="${1:?Usage: bash scripts/check-links.sh <dir> [glob]}"
glob="${2:-*.md}"; dir="${dir%/}"
shopt -s nullglob globstar; files=("$dir"/$glob)

# 1. Extract unique URLs and track first source file
url_pairs=$(for f in "${files[@]+"${files[@]}"}"; do
  [ -f "$f" ] || continue
  { grep -ohE 'https?://[^ |)>`"'"'"']+' "$f" 2>/dev/null || true; } | sed 's/[.,;:]*$//' | awk -v f="$f" 'NF {print f "\t" $0}'
done | awk -F'\t' '!seen[$2]++')

# 2 & 3. Check URLs in parallel (xargs -P 12) and classify
results=""
if [ -n "$url_pairs" ]; then
  results=$(printf "%s\n" "$url_pairs" | awk -F'\t' '{printf "%s\0%s\0", $1, $2}' | \
    xargs -0 -P 12 -n 2 bash -c '
      f="$1"; u="$2"
      res=$(curl -s -o /dev/null -L -m 20 -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/130" -w "%{http_code} %{url_effective}" "$u" || true)
      code="${res%% *}"; eff="${res#* }"
      [ -z "$code" ] && code="000"
      { [ -z "$eff" ] || [ "$eff" = "$code" ]; } && eff="$u"
      class="OK"
      if [ "$code" = "404" ] || [ "$code" = "410" ]; then class="DEAD"
      elif [ "$code" = "401" ] || [ "$code" = "403" ] || [ "$code" = "429" ]; then class="BLOCKED"
      elif [ "$code" = "000" ] || [ "$code" -ge 400 2>/dev/null ]; then class="NO-RESPONSE"
      elif [ "$code" = "200" ]; then
        if echo "$eff" | grep -qiE "catalogsearch|/search|\?q=|notfound"; then class="SOFT-404"
        else
          # Soft 404: store redirected product link to home or root path
          ur="${u#*://}"; up=""; [[ "$ur" == */* ]] && up="/${ur#*/}"; up="${up%%\?*}"; up="${up%%\#*}"
          er="${eff#*://}"; ep=""; [[ "$er" == */* ]] && ep="/${er#*/}"; ep="${ep%%\?*}"; ep="${ep%%\#*}"
          [ "${#up}" -gt 1 ] && { [ -z "$ep" ] || [ "$ep" = "/" ]; } && class="SOFT-404"
        fi
      fi
      printf "%s\t%s\t%s\n" "$class" "$f" "$u"
    ' _ | sort)
fi

# 4, 5, 6. Print summary per file, drops, and blocked URLs
{
  for f in "${files[@]+"${files[@]}"}"; do [ -f "$f" ] && printf "FILE\t%s\n" "$f"; done
  [ -n "$results" ] && printf "%s\n" "$results"
} | awk -F'\t' '
  $1 == "FILE" { files[++n] = $2; next }
  NF >= 3 {
    c = $1; f = $2; u = $3; tot[f]++; cnt[f, c]++
    if (c == "DEAD" || c == "SOFT-404") drop[++drop_n] = sprintf("%s %s %s", c, f, u)
    if (c == "BLOCKED") blk[++blk_n] = sprintf("%s %s %s", c, f, u)
  }
  END {
    for (i = 1; i <= n; i++) {
      f = files[i]
      printf "%s: total %d, ok %d, dead %d, soft404 %d, blocked %d, no-response %d\n", \
        f, tot[f]+0, cnt[f,"OK"]+0, cnt[f,"DEAD"]+0, cnt[f,"SOFT-404"]+0, cnt[f,"BLOCKED"]+0, cnt[f,"NO-RESPONSE"]+0
    }
    print "--- drop these (dead or soft 404):"; for (i = 1; i <= drop_n; i++) print drop[i]
    print "--- confirm by phone (blocked):"; for (i = 1; i <= blk_n; i++) print blk[i]
  }
'

exit 0
