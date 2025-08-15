#!/usr/bin/env bash
set -euo pipefail
PLAN="./MASTER_PLAN_TAGGED_v5.md"
LOGDIR="./docs/automation/LOGS"; mkdir -p "$LOGDIR"
RUNLOG="./docs/RUNLOG.md"; touch "$RUNLOG"

ts(){ date +"%Y-%m-%d %H:%M:%S %z"; }
log(){ echo "[$(ts)] $*" | tee -a "$RUNLOG"; }

need(){
  command -v "$1" >/dev/null || { echo "ERROR: missing '$1' in PATH" | tee -a "$RUNLOG"; exit 1; }
}
need claude
need awk
need python3

# Find next unchecked checkbox (- [ ])
next_task_line(){
  awk '/^- \[ \]/{print NR":"$0; exit}' "$PLAN"
}

mark_in_progress(){
  local n="$1"
  local tmp=$(mktemp)
  awk -v n="$n" 'NR==n{gsub("- \\[ \\]","- [⏳]")}1' "$PLAN" > "$tmp" && mv "$tmp" "$PLAN"
}

mark_done(){
  local n="$1"
  local tmp=$(mktemp)
  awk -v n="$n" 'NR==n{gsub("- \\[[^]]*\\]","- [x]")}1' "$PLAN" > "$tmp" && mv "$tmp" "$PLAN"
}

# Parse a human time (e.g., "8:01 AM", "2025-08-16 02:30") to epoch; return 0 on success
to_epoch(){
  python3 - "$1" <<'PY'
import sys,datetime as dt,time
s=sys.argv[1]
for fmt in ("%Y-%m-%d %H:%M","%Y-%m-%d %H:%M:%S","%I:%M %p","%H:%M"):
    try:
        t=dt.datetime.strptime(s,fmt)
        # If format without date, assume today; if already passed, bump to tomorrow
        if fmt in ("%I:%M %p","%H:%M"):
            now=dt.datetime.now()
            t=t.replace(year=now.year,month=now.month,day=now.day)
            if t < now:
                t = t + dt.timedelta(days=1)
        print(int(t.timestamp()))
        sys.exit(0)
    except: pass
# try "in N minutes" form like "Retry in 27 minutes"
import re
m=re.search(r'(\d+)\s*(minute|min|m)\b', s, re.I)
if m:
    print(int(time.time()) + int(m.group(1))*60)
    sys.exit(0)
# try seconds
m=re.search(r'(\d+)\s*(second|sec|s)\b', s, re.I)
if m:
    print(int(time.time()) + int(m.group(1)))
    sys.exit(0)
sys.exit(1)
PY
}

# Extract a "retry at" or "retry in" hint from Claude output and convert to sleep seconds
cooldown_sleep(){
  local file="$1"
  # common patterns: "try again at 08:01 AM", "retry after 23 minutes", "come back at 02:30"
  local when=""
  when=$(grep -Eoi 'try again at[^0-9A-Za-z]*([0-9: ]+(AM|PM))' "$file" | tail -n1 | sed -E 's/.*at[^0-9]*//') || true
  if [ -z "$when" ]; then
    when=$(grep -Eoi 'come back at[^0-9A-Za-z]*([0-9: ]+(AM|PM))' "$file" | tail -n1 | sed -E 's/.*at[^0-9]*//') || true
  fi
  if [ -z "$when" ]; then
    when=$(grep -Eoi 'retry (in|after)[^0-9]*([0-9]+ *(minutes?|mins?|m|seconds?|secs?|s))' "$file" | tail -n1 | sed -E 's/.*(in|after)[^0-9]*//') || true
  fi
  if [ -n "$when" ]; then
    if epoch=$(to_epoch "$when" 2>/dev/null); then
      local now=$(date +%s)
      local sleepfor=$(( epoch - now ))
      [ $sleepfor -lt 5 ] && sleepfor=5
      echo "$sleepfor"
      return 0
    fi
  fi
  return 1
}

log "MASTER_PLAN runner started (file: $PLAN)"

while true; do
  NEXT=$(next_task_line || true)
  if [ -z "$NEXT" ]; then
    log "No unchecked tasks left. Exiting."
    exit 0
  fi

  LINENO=${NEXT%%:*}
  RAWLINE=${NEXT#*: }
  TASK=$(sed -E 's/^- \[ \] *//' <<<"$RAWLINE")

  mark_in_progress "$LINENO"
  log "Executing task (line $LINENO): $TASK"

  PROMPT=$(cat <<EOF
UFOBeep – Execute this task exactly:
"$TASK"

Rules:
- Work only inside /home/mike/D/ufobeep.
- Record commands and notes prefixed with "LOG:" so I see them in the transcript.
- Keep commits small. At the end output exactly one line:
  STATUS: DONE
  or
  STATUS: BLOCKED: <short reason>
EOF
)
  TLOG="$LOGDIR/claude_$(date +%Y%m%d-%H%M%S).log"
  echo "$PROMPT" | claude | tee "$TLOG"

  if grep -q '^STATUS: DONE' "$TLOG"; then
    mark_done "$LINENO"
    log "Done: (line $LINENO). Proceeding to next."
    sleep 5
    continue
  fi

  # If time/usage banned, parse next allowed time and sleep
  if cooldown=$(cooldown_sleep "$TLOG"); then
    log "Hit cooldown. Sleeping ${cooldown}s, then resuming…"
    sleep "$cooldown"
    continue
  fi

  # If blocked for another reason, leave ⏳ so you can reorder, then re-check later
  if grep -q '^STATUS: BLOCKED' "$TLOG"; then
    log "Blocked: $(grep '^STATUS: BLOCKED' "$TLOG" | sed 's/^STATUS: //')"
    log "Leaving task as ⏳. Rechecking in 3 minutes."
    sleep 180
    continue
  fi

  # No STATUS line: retry later
  log "No STATUS line detected. Retrying in 2 minutes."
  sleep 120
done
