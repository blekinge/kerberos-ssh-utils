#!/usr/bin/env bash
if ! echo $LD_LIBRARY_PATH | $GREP -q "$CONDA_PREFIX/lib(:|$)"; then
LD_LIBRARY_PATH=$LD_LIBRARY_PATH${LD_LIBRARY_PATH:+:}$CONDA_PREFIX/lib
fi
export LD_LIBRARY_PATH