#!/usr/bin/python3

import os
import signal
import sys
import time
from supervisor.childutils import listener

# configuration
exit_wait = int(os.getenv('ENDPOINT_REMOVE_TIMEOUT', '5'))
supervisor_pid = 1

if os.path.exists('/tmp/supervisord.pid'):
    with open('/tmp/supervisord.pid', 'r') as f:
        supervisor_pid = int(f.read())

# this blocks container shutdown for X seconds in order to wait for endpoints to be updated
block_shutdown = True

def signal_handler(signum, frame):
    if block_shutdown:
        time.sleep(exit_wait)
    sys.exit(0)

signal.signal(signal.SIGTERM, signal_handler)
signal.signal(signal.SIGQUIT, signal_handler)

# if any process transitions to FATAL state we ask supervisord to exit
while True:
    headers, body = listener.wait(sys.stdin, sys.stdout)

    try:
        if headers['eventname'] == 'PROCESS_STATE_FATAL':
            block_shutdown = False
            os.kill(supervisor_pid, signal.SIGTERM)
    except Exception as e:
        listener.fail(sys.stdout)
        sys.exit(1)
    else:
        listener.ok(sys.stdout)
