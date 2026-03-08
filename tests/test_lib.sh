#!/bin/sh

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_file_exists() {
  [ -f "$1" ] || fail "expected file to exist: $1"
}

assert_dir_exists() {
  [ -d "$1" ] || fail "expected directory to exist: $1"
}

assert_not_exists() {
  [ ! -e "$1" ] || fail "expected path not to exist: $1"
}

assert_contains() {
  haystack=$1
  needle=$2
  printf '%s' "$haystack" | grep -F "$needle" >/dev/null || fail "expected output to contain: $needle"
}

assert_files_equal() {
  cmp -s "$1" "$2" || fail "expected files to match: $1 $2"
}

run_test() {
  test_name=$1

  if command -v setup_test >/dev/null 2>&1; then
    setup_test
  fi

  "$test_name"

  if command -v teardown_test >/dev/null 2>&1; then
    teardown_test
  fi
}
