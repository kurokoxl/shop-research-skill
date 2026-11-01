#!/usr/bin/env bash
set -euo pipefail

BASE="${1:-}"
HEAD="${2:-}"

if [[ -z "$BASE" || -z "$HEAD" ]]; then
  echo "::error::Usage: $0 <BASE> <HEAD>"
  exit 1
fi

# 0. Skip content checks for repo owner PRs
if [[ -n "${PR_AUTHOR:-}" && "${PR_AUTHOR:-}" == "${REPO_OWNER:-}" ]]; then
  echo "Owner PR: skipping content rules"
  exit 0
fi

errors=()
err() { errors+=("$1"); }

# 1. Changed files path check
mapfile -t changed_files < <(git diff --name-only "$BASE" "$HEAD")
allowed_files=()
file_regex='^references/(stores-[a-z-]+\.md|categories\.md|lessons\.md)$'

for f in "${changed_files[@]}"; do
  [[ -z "$f" ]] && continue
  if [[ "$f" =~ $file_regex ]]; then
    allowed_files+=("$f")
  else
    err "Disallowed file changed: $f"
  fi
done

total_added=0
total_removed=0
lesson_regex='^- 20[0-9]{2}-[0-9]{2}-[0-9]{2}: '
bad_hosts='(\.|^)(duckdns\.org|ngrok\.io|ngrok-free\.app|trycloudflare\.com|bit\.ly|tinyurl\.com|t\.co|goo\.gl)$'
ipv4_regex='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'
inj_regex='ignore (all |any |the )?(previous|prior|above|earlier)|disregard|system prompt|you are now|new instructions|as an ai|run (this|the following|the) command|execute|powershell|cmd\.exe|bash -c|curl|wget|rm -rf|invoke-webrequest|<script|javascript:|api[ _-]?key|password|secret|token|send (your|the|all)|upload|exfiltrat|base64'

for f in "${allowed_files[@]}"; do
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    if [[ "$line" =~ ^\+\+\+ ]]; then
      continue
    elif [[ "$line" =~ ^\+ ]]; then
      total_added=$((total_added + 1))
      content="${line:1}"

      # 2. Line length limit (500 chars)
      if (( ${#content} > 500 )); then
        err "Line exceeds 500 characters in $f: ${content:0:60}"
      fi

      # 3. Store table formatting (2 or 4 cells)
      if [[ "$f" == references/stores-*.md && -n "${content//[[:space:]]/}" ]]; then
        pipes="${content//[^|]/}"
        if [[ "$content" != '| '* || "$content" != *' |' || ( ${#pipes} -ne 3 && ${#pipes} -ne 5 ) ]]; then
          err "Invalid table row format in $f: $content"
        fi
      fi

      # 4. Lessons date prefix check
      if [[ "$f" == references/lessons.md && -n "${content//[[:space:]]/}" ]]; then
        if ! [[ "$content" =~ $lesson_regex ]]; then
          err "Invalid lesson format in $f: $content"
        fi
      fi

      # 5. URL validations
      while IFS= read -r url; do
        [[ -z "$url" ]] && continue
        if ! [[ "$url" =~ ^https:// ]]; then
          err "Insecure URL (must use https): $url"
        fi
        host="${url#*://}"
        host="${host%%[/?#]*}"
        host="${host##*@}"
        host="${host%%:*}"
        if [[ "$host" =~ $ipv4_regex ]]; then
          err "URL host must not be raw IPv4: $url"
        fi
        if [[ "$host" =~ $bad_hosts ]]; then
          err "Forbidden URL host in $url"
        fi
      done < <(printf '%s\n' "$content" | grep -oE 'https?://[^ |)>]+' || true)

      # 6. Instruction / prompt injection check
      if printf '%s\n' "$content" | grep -Eiq "$inj_regex"; then
        err "Line looks like an instruction to the AI"
      fi

      # 7. Non-printable control characters check
      clean="${content//$'\t'/}"
      if [[ "$clean" =~ [[:cntrl:]] ]]; then
        err "Non-printable control characters in $f: ${content:0:60}"
      fi

    elif [[ "$line" =~ ^--- ]]; then
      continue
    elif [[ "$line" =~ ^- ]]; then
      total_removed=$((total_removed + 1))
    fi
  done < <(git diff -U0 "$BASE" "$HEAD" -- "$f")
done

# 2. Total added and removed line limits
if (( total_added > 60 )); then
  err "Too many added lines ($total_added > 60)"
fi
if (( total_removed > 15 )); then
  err "Too many removed lines ($total_removed > 15)"
fi

if (( ${#errors[@]} > 0 )); then
  for e in "${errors[@]}"; do
    echo "::error::$e"
  done
  exit 1
fi

echo "All checks passed"
exit 0
