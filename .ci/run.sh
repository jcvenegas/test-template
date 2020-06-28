#!/usr/bin/env bash
#
# Copyright (c) 20XX Carlos Venegas <vmjcarlos@gmail.com>
#
# SPDX-License-Identifier: Apache-2.0 OR MIT

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

script_name=${0##*/}
script_dir=$(dirname "$(readlink -f "$0")")

die() {
	local msg="$*"
	echo "ERROR: $msg" >&2
	exit 1
}

warn() {
	local msg="$*"
	echo "WARNING: $msg" >&2
}

info() {
	local msg="$*"
	echo "INFO: $msg" >&2
}

handle_error() {
	local exit_code="${?}"
	local line_number="${1:-}"
	echo "Failed at ${script_dir}/${script_name} +$line_number: ${BASH_COMMAND}"
	exit "${exit_code}"
}

update_cargo_toml_template() {
	origin=$(git remote get-url --push origin)
	local service
	local repo_org
	if echo "${origin}" | grep github; then
		service="github"
		if echo "${origin}" | grep https; then
			repo_org="${origin#https://github.com/}"
		elif echo "${origin}" | grep "git@"; then
			repo_org="${origin#git@github.com:}"
		fi
		repo_org=${repo_org%.git}
	fi
	sed -i "s|@repo_org@|${repo_org}|g" Cargo.toml
	sed -i "s|@git_service@|${service}|g" Cargo.toml
}

trap 'handle_error $LINENO' ERR

# shellcheck disable=SC1090
command -v cargo || source "$HOME/.cargo/env"

if [ "${CI:-}" != "true" ]; then
	info "Update template values"
	update_cargo_toml_template

	info "Running cargo-audit"
	cargo audit

	info "Running cargo-deny"
	cargo deny check

	info "update cargo.lock"
	cargo update

	info "Running cargo-outdated"
	cargo outdated --exit-code 1

	info "Running cargo-readme"
	cargo readme >README.md

	info "Running cargo-tree"
	cargo tree
fi

info "Running clippy"
cargo clippy --all-targets --all-features -- -D warnings
cargo clippy --all -- -D warnings

info "Running cargo fmt"
cargo fmt -- --check

info "Running tests"
cargo build
cargo test
