#!/usr/bin/env bash
#
# Copyright (c) 20XX Jose Carlos Venegas Munoz <jose.carlos.venegas.munoz@intel.com>
#
# SPDX-License-Identifier: Apache-2.0 OR MIT

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

script_name=${0##*/}

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
	echo "Failed at ${script_name} +${line_number}: ${BASH_COMMAND}"
	exit "${exit_code}"
}

trap 'handle_error $LINENO' ERR


declare -A package_install_map
package_install_map[cargo-update]="libssl-dev"

package_install_list=""
for pkgs in "${package_install_map[@]}"; do
	package_install_list+=" $pkgs"
done

sudo -E apt -y install ${package_install_list}
