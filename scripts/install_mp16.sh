#!/usr/bin/env bash
set -euo pipefail
REPO="${HOME}/D/ufobeep"
echo ">> Installing into ${REPO}"
mkdir -p "${REPO}"
cd "${REPO}"
# Unpack relative to this repo
pwd
echo ">> Files are ready to be copied from the extracted bundle directory."
echo "   If you are reading this script from the bundle, you already have the files."
echo "   Next steps:"
cat <<'ASCII'
1) git checkout -b mp16/docs-and-starters
2) git add README.md docs/* api/tests/* api/app/routers/*
3) git commit -m "docs(mp16): add MASTER_PLAN_v16; endpoints; tests; starter routers"
4) git push -u origin mp16/docs-and-starters
5) Wire routers in api/app/main.py, add Pillow to requirements.txt
6) Run tests in api/tests
ASCII
