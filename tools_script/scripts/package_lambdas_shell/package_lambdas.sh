#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------
# Packages every lambda folder under repo-root/lambda_backend
# - If requirements.txt exists -> pip install -t <pkg_dir>
# - If package.json exists     -> npm ci --omit=dev into <pkg_dir>
# - Otherwise                  -> just zip sources
#
# OUTPUT: lambda_backend/<LambdaName>/<LambdaName>.zip
# -------------------------------------------------------

# Absolute path to this script and repo root
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"

# Base dir with all lambdas (override with LAMBDA_BASE_DIR_OVERRIDE if you need)
LAMBDA_BASE_DIR="${LAMBDA_BASE_DIR_OVERRIDE:-$REPO_ROOT/lambda_backend}"

# Temp workspace
WORK_ROOT="$(mktemp -d -t lambda_pkg_XXXXXX)"
cleanup() { rm -rf "$WORK_ROOT" || true; }
trap cleanup EXIT

echo "Repo root:         $REPO_ROOT"
echo "Lambda base dir:   $LAMBDA_BASE_DIR"
echo "Working in:        $WORK_ROOT"
echo

[[ -d "$LAMBDA_BASE_DIR" ]] || { echo "ERROR: $LAMBDA_BASE_DIR not found"; exit 1; }

# Helper: install Python deps if requirements.txt exists
install_python_deps() {
  local src_dir="$1" pkg_dir="$2"
  if [[ -f "$src_dir/requirements.txt" ]]; then
    echo "  • Installing Python deps from requirements.txt"
    python3 -m pip install --upgrade pip >/dev/null
    python3 -m pip install -r "$src_dir/requirements.txt" -t "$pkg_dir" >/dev/null
  fi
}

# Helper: install Node deps if package.json exists
install_node_deps() {
  local src_dir="$1" pkg_dir="$2"
  if [[ -f "$src_dir/package.json" ]]; then
    echo "  • Installing Node deps (npm ci --omit=dev)"
    mkdir -p "$pkg_dir"
    cp "$src_dir/package.json" "$pkg_dir/"
    [[ -f "$src_dir/package-lock.json" ]] && cp "$src_dir/package-lock.json" "$pkg_dir/"
    ( cd "$pkg_dir" && npm ci --omit=dev --no-audit --no-fund >/dev/null )
  fi
}

# Helper: copy sources (common languages) excluding junk
copy_sources() {
  local src_dir="$1" pkg_dir="$2"
  echo "  • Copying sources"
  rsync -a \
    --include='*/' \
    --include='*.py' --include='*.js' --include='*.ts' \
    --include='*.mjs' --include='*.cjs' \
    --include='*.json' --include='*.txt' \
    --include='*.html' --include='*.css' \
    --exclude='.git/' --exclude='node_modules/' \
    --exclude='__pycache__/' --exclude='.pytest_cache/' \
    --exclude='.mypy_cache/' --exclude='.venv/' --exclude='venv/' \
    --exclude='tests/' --exclude='*.test.*' \
    "$src_dir/" "$pkg_dir/"
}

# Helper: zip folder
zip_lambda() {
  local lambda_name="$1" pkg_dir="$2" out_zip="$3"
  echo "  • Creating zip -> $out_zip"
  ( cd "$pkg_dir" && zip -qr "$out_zip" . )
}

# Discover lambdas: immediate subfolders under lambda_backend/
shopt -s nullglob
LAMBDAS=( "$LAMBDA_BASE_DIR"/*/ )
shopt -u nullglob

if (( ${#LAMBDAS[@]} == 0 )); then
  echo "No lambdas found in $LAMBDA_BASE_DIR"
  exit 0
fi

echo "Found ${#LAMBDAS[@]} lambda(s):"
for d in "${LAMBDAS[@]}"; do echo "  - $(basename "$d")"; done
echo

for lambda_dir in "${LAMBDAS[@]}"; do
  lambda_name="$(basename "$lambda_dir")"
  echo "Packaging: $lambda_name"

  pkg_dir="$WORK_ROOT/$lambda_name"
  mkdir -p "$pkg_dir"

  # Only install deps if the files exist
  install_python_deps "$lambda_dir" "$pkg_dir"
  install_node_deps   "$lambda_dir" "$pkg_dir"

  # Copy source code
  copy_sources "$lambda_dir" "$pkg_dir"

  # Output zip path (next to source)
  out_zip="$lambda_dir/$lambda_name.zip"
  rm -f "$out_zip"

  # Zip it
  zip_lambda "$lambda_name" "$pkg_dir" "$out_zip"
  echo "Done: $out_zip"
  echo
done

echo "All lambdas packaged."
