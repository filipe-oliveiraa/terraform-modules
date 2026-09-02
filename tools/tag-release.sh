#!/usr/bin/env bash
# Tags a release for one module.
#
#   ./tools/tag-release.sh iam-role 1.0.0
#   ./tools/tag-release.sh security-group 2.0.0 --push
#
# Tags are <module>/vX.Y.Z. The separator is "/" on purpose: with a "-", the tag
# iam-role-v1.0.0 is a prefix match for iam-role-policy-attachment-v1.0.0, so
# anything filtering tags by module prefix picks up both.
set -euo pipefail

cd "$(dirname "$0")/.."

usage() { echo "usage: $0 <module-name> <x.y.z> [--push]" >&2; exit 2; }

[ $# -ge 2 ] || usage
MODULE="$1"
VERSION="$2"
PUSH="${3:-}"

if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "error: version must be x.y.z (no leading v), got '$VERSION'" >&2
  exit 1
fi

DIR="$(find aws -mindepth 2 -maxdepth 2 -type d -name "$MODULE" | head -1 || true)"
if [ -z "$DIR" ]; then
  echo "error: no module named '$MODULE' under aws/" >&2
  echo "available:" >&2
  find aws -mindepth 2 -maxdepth 2 -type d -exec basename {} ';' | sort | sed 's/^/  /' >&2
  exit 1
fi

TAG="$MODULE/v$VERSION"

if git rev-parse -q --verify "refs/tags/$TAG" >/dev/null; then
  echo "error: tag $TAG already exists. Versions are immutable once pushed." >&2
  exit 1
fi

# Release from a clean tree only: a tag pointing at a commit that does not match
# what was tested is worse than no tag.
if [ -n "$(git status --porcelain)" ]; then
  echo "error: working tree is dirty. Commit or stash first." >&2
  exit 1
fi

echo "==> validating $DIR"
( cd "$DIR" && terraform init -backend=false -input=false >/dev/null && terraform validate )
if [ -d "$DIR/tests" ]; then
  echo "==> testing $DIR"
  ( cd "$DIR" && terraform test )
else
  echo "warning: $DIR has no tests/ directory" >&2
fi

echo "==> tagging $TAG at $(git rev-parse --short HEAD)"
git tag -a "$TAG" -m "$MODULE v$VERSION"

if [ "$PUSH" = "--push" ]; then
  git push origin "$TAG"
  echo "pushed $TAG"
else
  echo "created $TAG locally. Push it with:"
  echo "  git push origin $TAG"
fi
