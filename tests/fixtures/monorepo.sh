#!/usr/bin/env bash
# Builds the realistic project the deep suite drives: a django backend, a
# vite/react/typescript frontend and a go service in one git repo, with an
# .http file, a sqlite db and real history so gitsigns has hunks to show.
#
# Usage: monorepo.sh <target-dir>
# Idempotent: an existing target with a .stamp of the current version is left
# alone, so `npm install` runs once and not on every suite run.
set -euo pipefail

VERSION=6
TARGET=${1:?usage: monorepo.sh <target-dir>}
STAMP="$TARGET/.stamp"

if [[ -f $STAMP && $(cat "$STAMP") == "$VERSION" ]]; then
  echo "monorepo already built at $TARGET"
  exit 0
fi

rm -rf "$TARGET"
mkdir -p "$TARGET"
cd "$TARGET"

# ---------- backend: django ----------
# its own venv, like a real project: the machine's global python may carry
# broken pytest plugins, and the dap python adapter follows VIRTUAL_ENV
mkdir -p backend
(
  cd backend
  python3 -m venv .venv
  .venv/bin/python -m pip install --quiet --upgrade pip
  .venv/bin/python -m pip install --quiet django pytest pytest-django
  .venv/bin/python -m django startproject core .
  cat >core/views.py <<'EOF'
from django.http import HttpResponse, JsonResponse

from .services import summarize


def index(request):
    numbers = [1, 2, 3, 4]
    total = summarize(numbers)
    return HttpResponse(f"total={total}")


def api_totals(request):
    numbers = [10, 20, 30]
    return JsonResponse({"total": summarize(numbers), "count": len(numbers)})
EOF
  cat >core/services.py <<'EOF'
def double(value):
    doubled = value * 2
    return doubled


def summarize(numbers):
    total = 0
    for number in numbers:
        total = total + double(number)
    return total
EOF
  .venv/bin/python - <<'EOF'
from pathlib import Path

urls = Path("core/urls.py")
text = urls.read_text()
text = text.replace(
    "from django.urls import path",
    "from django.urls import path\n\nfrom . import views",
)
text = text.replace(
    'path("admin/", admin.site.urls),',
    'path("admin/", admin.site.urls),\n    path("", views.index),\n    path("api/totals/", views.api_totals),',
)
urls.write_text(text)
EOF
  mkdir -p tests
  touch tests/__init__.py
  cat >tests/test_services.py <<'EOF'
from core.services import double, summarize


def test_double():
    result = double(21)
    assert result == 42


def test_summarize():
    result = summarize([1, 2])
    assert result == 6


class TestServices:
    def test_double_negative(self):
        result = double(-3)
        assert result == -6
EOF
  # entry point for "Launch file": the breakpoints go in services.py, so a
  # session has to step across files, like a real one does
  cat >demo.py <<'EOF'
from core.services import summarize

numbers = [1, 2, 3, 4]
print("total", summarize(numbers))
EOF
  # a real repo has lint findings; this one gives the diagnostic keymaps
  # something to jump to
  cat >core/legacy.py <<'EOF'
import json
import os


def legacy_total(numbers):
    total = 0
    for number in numbers:
        total = total + number
    return total
EOF
  printf 'django>=4.2\npytest\npytest-django\n' >requirements.txt
  printf '[pytest]\nDJANGO_SETTINGS_MODULE = core.settings\npythonpath = .\n' >pytest.ini
)

# ---------- service: go ----------
mkdir -p service
(
  cd service
  cat >go.mod <<'EOF'
module service

go 1.21
EOF
  cat >math.go <<'EOF'
package main

func double(value int) int {
	doubled := value * 2
	return doubled
}

func summarize(numbers []int) int {
	total := 0
	for _, number := range numbers {
		total = total + double(number)
	}
	return total
}
EOF
  cat >main.go <<'EOF'
package main

import "fmt"

func main() {
	numbers := []int{1, 2, 3, 4}
	total := summarize(numbers)
	fmt.Println("total", total)
}
EOF
  cat >math_test.go <<'EOF'
package main

import "testing"

func TestDouble(t *testing.T) {
	got := double(21)
	if got != 42 {
		t.Fatalf("got %d, want 42", got)
	}
}

func TestSummarize(t *testing.T) {
	got := summarize([]int{1, 2})
	if got != 6 {
		t.Fatalf("got %d, want 6", got)
	}
}
EOF
)

# ---------- frontend: vite + react + typescript ----------
# the default registry on this machine can be a private one with an expired
# token, so pin the public registry for this throwaway project only
npm create --registry=https://registry.npmjs.org/ vite@latest frontend -- --template react-ts >/dev/null
(
  cd frontend
  printf 'registry=https://registry.npmjs.org/\n' >.npmrc
  npm install >/dev/null 2>&1
  mkdir -p src/lib
  cat >src/lib/math.ts <<'EOF'
export function double(value: number): number {
  const doubled: number = value * 2;
  return doubled;
}

export function summarize(numbers: number[]): number {
  let total: number = 0;
  for (const number of numbers) {
    total = total + double(number);
  }
  return total;
}
EOF
  cat >src/worker.ts <<'EOF'
// the .ts extension is what lets node run this file directly; tsconfig has
// allowImportingTsExtensions, and vite resolves it too
import { summarize } from "./lib/math.ts";

async function main(): Promise<void> {
  const numbers: number[] = [1, 2, 3, 4];
  for (const number of numbers) {
    console.log("step", number, summarize([number]));
    await new Promise((resolve) => setTimeout(resolve, 200));
  }
}

main();
EOF
  cat >src/App.tsx <<'EOF'
import { useState } from "react";
import { summarize } from "./lib/math";
import "./App.css";

function App() {
  const [count, setCount] = useState(0);
  const total = summarize([count, count + 1]);

  return (
    <main>
      <h1>Totals</h1>
      <button type="button" onClick={() => setCount(count + 1)}>
        count is {count}
      </button>
      <p>total is {total}</p>
    </main>
  );
}

export default App;
EOF
)

# ---------- odds and ends a real repo has ----------
cat >api.http <<'EOF'
GET http://127.0.0.1:8000/api/totals/
Accept: application/json
EOF
cat >notes.md <<'EOF'
# Notes

Backend, frontend and service live in one repo on purpose: the debug
configurations have to cope with more than one language per session.
EOF
cat >README.md <<'EOF'
# monorepo

Test fixture. Django backend, React frontend, Go service.
EOF
command -v sqlite3 >/dev/null && sqlite3 data.db \
  "create table totals (id integer primary key, label text, value integer); insert into totals (label, value) values ('first', 20), ('second', 40);"

printf 'node_modules/\n__pycache__/\n*.pyc\ndata.db\n.venv/\n' >.gitignore

# ---------- history, so gitsigns has something real to draw ----------
git init -q
git -c user.email=deep@test -c user.name=deep add -A
git -c user.email=deep@test -c user.name=deep commit -qm "initial monorepo"
printf '\n# appended after the first commit\n' >>notes.md
git -c user.email=deep@test -c user.name=deep add notes.md
git -c user.email=deep@test -c user.name=deep commit -qm "extend the notes"

echo "$VERSION" >"$STAMP"
echo "monorepo built at $TARGET"
