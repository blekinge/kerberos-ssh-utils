( \
    [ -e "/tmp/krenew_$UID.pid" ] && \
    ps --quick-pid "$(cat "/tmp/krenew_$UID.pid")" >/dev/null \
) || \
( \
command -v krenew >/dev/null && \
krenew -a -K 2 -L -b -p -- "/tmp/krenew_$UID.pid" \
)
