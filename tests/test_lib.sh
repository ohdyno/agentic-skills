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

assert_not_contains() {
  haystack=$1
  needle=$2
  if printf '%s' "$haystack" | grep -F "$needle" >/dev/null; then
    fail "expected output not to contain: $needle"
  fi
}

assert_files_equal() {
  cmp -s "$1" "$2" || fail "expected files to match: $1 $2"
}

assert_directory_files_match() {
  expected_dir=$1
  actual_dir=$2
  file_list=$(mktemp "${TMPDIR:-/tmp}/agentic-skills-test-files.XXXXXX")

  assert_dir_exists "$expected_dir"
  assert_dir_exists "$actual_dir"

  (cd "$expected_dir" && find . -type f -print | LC_ALL=C sort) >"$file_list"

  while IFS= read -r relative_path; do
    relative_path=${relative_path#./}
    assert_file_exists "$actual_dir/$relative_path"
    assert_files_equal "$expected_dir/$relative_path" "$actual_dir/$relative_path"
  done <"$file_list"

  rm -f "$file_list"
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
