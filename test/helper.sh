run_restyler_cmd() {
  local name=$1
  local command=$2
  shift 2

  local paths=()
  local path
  local image

  if [ "${USE_MANIFEST:-0}" -eq 1 ]; then
    image=$(grep "^restyled/restyler-$name:" "$TESTDIR"/../manifest)
  else
    image=restyled/restyler-$name:latest
  fi

  if ! docker run --rm --net none --volume "$PWD":/code "$image" "$command" "$@"; then
    echo "Restyler errored" >&2
    exit 1
  fi

  for path; do
    if [ -e "$path" ]; then
      paths+=("$path")
    fi
  done

  git diff "${paths[@]}"
}

run_restyler() {
  local name=$1
  shift

  run_restyler_cmd "$name" "$name" "$@"
}

set -e

mkdir repo
cd repo
cp "$TESTDIR"/fixtures/* .

{
  git init
  git add .
  git commit -m "Add fixture files"
} >/dev/null

echo "If you don't see this, setup failed"
set +e
