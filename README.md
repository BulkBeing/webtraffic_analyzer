# webtraffic_analyzer
Provides a sorted output of the clear text requests coming to port 80 using tcpdump capture.

Usage:

perl webtrafficdump.pl <INTERVEL_IN_SECONDS>

INTERVEL_IN_SECONDS determines how long the tcpdump caputres traffic before printing them to screen. If no arguments provides, it monitors for 10 seconds by default.
