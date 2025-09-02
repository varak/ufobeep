#!/usr/bin/env bash
set -euo pipefail
python login_and_search.py 2>&1 | tee LOGIN_RUN_LOG.txt
python extend_mufon_details.py 2>&1 | tee CLICK_RUN_LOG.txt
