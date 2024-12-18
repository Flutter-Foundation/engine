#!/usr/bin/env bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# ---------------------------------- NOTE ----------------------------------
#
# Please keep the logic in this file consistent with the logic in the
# `yapf.bat` script in the same directory to ensure that it continues to
# work across all platforms!
#
# --------------------------------------------------------------------------

# Generates objc docs for Flutter iOS libraries.

set -e

# On Mac OS, readlink -f doesn't work, so follow_links traverses the path one
# link at a time, and then cds into the link destination and find out where it
# ends up.
#
# The function is enclosed in a subshell to avoid changing the working directory
# of the caller.
function follow_links() (
  cd -P "$(dirname -- "$1")"
  file="$PWD/$(basename -- "$1")"
  while [[ -h "$file" ]]; do
    cd -P "$(dirname -- "$file")"
    file="$(readlink -- "$file")"
    cd -P "$(dirname -- "$file")"
    file="$PWD/$(basename -- "$file")"
  done
  echo "$file"
)

SCRIPT_DIR=$(follow_links "$(dirname -- "${BASH_SOURCE[0]}")")
SRC_DIR="$(cd "$SCRIPT_DIR/../.."; pwd -P)"
YAPF_DIR="$(cd "$SRC_DIR/flutter/third_party/yapf"; pwd -P)"
if command -v python3.10 &> /dev/null; then
  PYTHON_EXEC="python3.10"
else
  python3 -c "
import sys
version = sys.version_info
if (version.major, version.minor) > (3, 11):
    print(f'Error: python3 version {version.major}.{version.minor} is greater than 3.11.', file=sys.stderr)
    sys.exit(1)
else:
    print(f'Using python3 version {version.major}.{version.minor}.')
" || exit 1
  PYTHON_EXEC="python3"
fi

PYTHONPATH="$YAPF_DIR" $PYTHON_EXEC "$YAPF_DIR/yapf" "$@"
