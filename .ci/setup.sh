#!/usr/bin/env bash
#
# Copyright (c) 2020 Carlos Venegas <vmjcarlos@gmail.com>
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

OK() {
	local msg="$*"
	echo "[  OK  ] $msg" >&2
}

handle_error() {
	local exit_code="${?}"
	local line_number="${1:-}"
	echo "Failed at ${script_name} +$line_number: ${BASH_COMMAND}"
	exit "${exit_code}"
}

cargo_install() {
	local -r program=${1}
	info "Install ${program}"
	command -v "${program}" || cargo install "${program}"
	OK "${program} installed"
}

trap 'handle_error $LINENO' ERR

# shellcheck disable=SC1091
source /etc/os-release

info "Install distro build deps"
"${script_dir}/setup-${ID}.sh"

info "Installing rust"
# shellcheck disable=SC1090
command -v cargo || curl -L --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s --  --profile default -q -y
cargo_env="${HOME}/.cargo/env"
if [ -f "${cargo_env}" ]; then
	source "${cargo_env}"
fi
OK "rust installed"

info "Install clippy"
cargo clippy || rustup component add clippy
OK "clippy installed"

if [ "${CI:-}" != "true" ]; then
	cargo_install cargo-audit
	cargo_install cargo-deny
	cargo_install cargo-outdated
	cargo_install cargo-readme
	cargo_install cargo-tree
	cargo_install cargo-udeps
fi
