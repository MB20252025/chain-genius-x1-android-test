#!/usr/bin/env bash
# Builds the temporary test site from ONE exact commit of chain-genius-consulting (21 Nov 2026).
# Usage: build-site.sh <source-repo> <commit> <site-worktree>
# Copies the same 15 application files as cd16dcc (runtime + 4 test workbooks + checklist) from <commit> via git show,
# writes the landing page, README and SOURCE-MANIFEST.sha256 naming the commit. Nothing is taken from a working tree.
set -euo pipefail
SRC=$1; C=$(git -C "$SRC" rev-parse "$2"); S=$3; A=applications/inventory-intelligence-engine
F="assets/SheetJS-LICENSE.txt assets/xlsx.mini.min.js css/styles.css index.html js/app.js js/calculations.js js/engine/engine-api.js js/excel-import.js js/forecasting.js js/validation/x1-integrity.js stage3-design/x1-implementation/ANDROID-CHECKLIST-FINAL.md stage3-design/x1-implementation/browser-evidence-20261121-final/workbooks/blank-material-id.xlsx stage3-design/x1-implementation/browser-evidence-20261121-final/workbooks/no-rop-column.xlsx stage3-design/x1-implementation/browser-evidence-20261121-material/workbooks/blank-line-full-bom.xlsx tests/fixtures/northstar/Chain_Genius_Project_001_Northstar_Dataset_1.xlsx"
# the app must load exactly the scripts we copy
for s in $(git -C "$SRC" show "$C:$A/index.html" | grep -oE 'src="[^"]+"' | sed 's/src="//;s/"//;s/?.*//'); do echo "$F" | grep -qw -- "$s" || { echo "index.html loads $s, which is not in the copy list"; exit 3; }; done
for f in $F; do mkdir -p "$S/$A/$(dirname $f)"; git -C "$SRC" show "$C:$A/$f" > "$S/$A/$f"; done
(cd "$S" && find "$A" -type f | sort | xargs sha256sum > SOURCE-MANIFEST.sha256)
cp /home/claude/w6/site-index.html "$S/index.html"; sed -i "s/@COMMIT@/$C/g; s/@SHORT@/${C:0:7}/g" "$S/index.html"
cp /home/claude/w6/site-README.md "$S/README.md"; sed -i "s/@COMMIT@/$C/g; s/@SHORT@/${C:0:7}/g" "$S/README.md"
touch "$S/.nojekyll"; echo "built from $C: $(wc -l < "$S/SOURCE-MANIFEST.sha256") application files"
