#!/usr/bin/env bash
# Structural verification for docs/jp-character-marketing-brief.md
# Drives the real brief file in-repo (research deliverable).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BRIEF="$ROOT/docs/jp-character-marketing-brief.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "OK: $*"; }

[[ -f "$BRIEF" ]] || fail "brief missing at $BRIEF"
pass "brief exists"

# Criterion 1 — core concepts
for s in "Yuru-chara" "Kawaii" "Brand kyara"; do
  grep -q "$s" "$BRIEF" || fail "missing concept section marker: $s"
done
pass "core concepts present"

# Criterion 2 — regional + grocery examples with traits
for s in "Kumamon" "Hikonyan" "Funassyi" "Kewpie" "Peko-chan" "Suica Penguin"; do
  grep -q "$s" "$BRIEF" || fail "missing named example: $s"
done
# trait language (not name-only)
grep -q "Why it works" "$BRIEF" || fail "missing marketing/design traits (Why it works)"
pass "named examples + traits present"

# Criterion 3 — design checklist
grep -q "Design pattern checklist" "$BRIEF" || fail "missing design checklist"
for s in "Big face" "One product job" "Signature gesture" "menu bar"; do
  grep -qi "$s" "$BRIEF" || fail "checklist missing pattern: $s"
done
pass "design checklist present"

# Criterion 4 — product options map to real snap behaviors (brief written for HalfSnap era)
grep -qE 'HalfSnap-specific|Snap Cat-specific|product.?specific' "$BRIEF" || fail "missing product options section"
for s in "⌘←" "⌘→" "⌘↑" "⌘↓" "left half" "right half" "fill" "minimize" "menu bar"; do
  grep -q "$s" "$BRIEF" || fail "product options missing fact: $s"
done
# 3–5 named options
count=0
for s in "Half-kun" "Mado-chan" "Snappei" "Warikuma" "Docko" "Snapu"; do
  if grep -q "$s" "$BRIEF"; then count=$((count + 1)); fi
done
[[ "$count" -ge 3 ]] || fail "need ≥3 name options, found $count"
pass "product options map to behaviors ($count names)"

# Rename recommendation
grep -qi "Do not rename" "$BRIEF" || fail "missing rename recommendation"
pass "rename recommendation present"

# Caveats prose
grep -qi "Trademark\|not legal advice" "$BRIEF" || fail "missing trademark/cultural caveats"
pass "caveats present"

echo "ALL CHECKS PASSED: $BRIEF"
