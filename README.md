# webtraffic_analyzer
Provides a sorted output of the clear text requests coming to port 80 using tcpdump capture.

Usage:

perl webtrafficdump.pl <INTERVEL_IN_SECONDS>

INTERVEL_IN_SECONDS determines how long the tcpdump caputres traffic before printing them to screen. If no arguments provides, it monitors for 10 seconds by default.


Requires Perl (I used 5.16) and tcpdump installed.

Additional perl module used is Parallel::ForkManager. If it is not installed, you can install it from cpan. Run this on your terminal:

`cpan install Parallel::ForkManager`

If cpan is not installed, install it first:

`yum install epel-release`
`yum install perl-CPAN`

To run script:

`perl webtrafficdump.pl <optional_timeout_in_seconds>`

The "Top Hosts" section will display the virtualhosts (domains) to which traffic is coming.
![](https://i.imgur.com/YeEHQ8J.png)
