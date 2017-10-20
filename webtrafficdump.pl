#!/usr/bin/perl
use strict;
use warnings;
use Parallel::ForkManager;

my $MONITOR_INTERVAL;
$MONITOR_INTERVAL = $ARGV[0] if defined $ARGV[0] && $ARGV[0] =~ m/^\d+$/;
$MONITOR_INTERVAL ||= 10;
my $NUM_RESULTS_TO_PRINT = 15;
my $pm = Parallel::ForkManager->new(1);

my $pid = $pm->start;
unless ($pid > 0) {
	system("tcpdump -nnAi any '(dst port 80 or dst port 443) and tcp[32:4] = 0x47455420' -w /tmp/tcpdump.log");
	$pm->finish(0, {});
}
#print "Main thread going to sleep\n";
sleep($MONITOR_INTERVAL);
print "[+] Sending kill signal to child\n";
kill 15, $pid;
$pm->wait_all_children;
open(my $fh, "<", "/tmp/tcpdump.log");

my %IP;
my %HOST;
my %REQ;
my %POST;
my $capture = scalar qx{tcpdump -nnAr /tmp/tcpdump.log '(dst port 80 or dst port 443) and tcp[32:4] = 0x47455420'};
foreach my $line (split /\n\n/, $capture) {
	if ($line =~ m/Host: (.*?)\n/ms) {
		$HOST{$1}++;
	};
	if ($line =~ m/ IP ([\d\.\s]*)> /ms){
		my $ip = $1;
		$ip =~ s/\.[\d]+ //;
		$IP{$ip}++;
	};
	if ($line =~ m/HTTP: GET (.*?) HTTP.*Host: (.*?)\n/ms){
		$REQ{"$2$1"}++;
	};
	if ($line =~ m/HTTP: POST (.*?) HTTP.*Host: (.*?)\n/ms) {
		$POST{"$2$1"}++;
	}
};

sub printit {
	my $full_hash = shift;
	my %full_hash = %$full_hash;
	my $c = $NUM_RESULTS_TO_PRINT;
	foreach my $value (sort { $full_hash{$b} <=> $full_hash{$a} } keys %full_hash) {
		last if $c <= 0;
		printf "  %10d  %s\n", $full_hash{$value}, $value;
		$c--;
	}

};

print "\n\nTop Hosts:\n";
printit(\%HOST);
print "\n\nTop IPs:\n";
printit(\%IP);
print "\n\nTop Requests:\n";
printit(\%REQ);
print "\n\nTop Posts:\n";
printit(\%POST);
print "\n\n";
