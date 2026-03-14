#!/usr/bin/env bash
set -euo pipefail

# Bootstrap Flutter deps and localization generation.
# Run from repo root: `bash tool/bootstrap_flutter.sh`

flutter --version
flutter pub get
flutter gen-l10n

echo "OK: deps fetched and l10n generated."

