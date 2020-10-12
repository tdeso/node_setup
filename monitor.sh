#!/bin/bash
journalctl -f -u avalanche -n 0 | awk '
/You may want to update your client/ { system ("$HOME/avalanche_setup/update.sh") }
/<P Chain>/ && /bootstrapping finished/ {print "P CHAIN SUCCESSFULLY BOOTSTRAPPED"}
/<X Chain>/ && /bootstrapping finished/ {print "X CHAIN SUCCESSFULLY BOOTSTRAPPED"}
/<C Chain>/ && /bootstrapping finished/ {print "C CHAIN SUCCESSFULLY BOOTSTRAPPED"}'
