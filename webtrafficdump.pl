#!/usr/bin/perl
use strict;
use warnings;
use Parallel::ForkManager;
use Data::Dumper;

my $pm = Parallel::ForkManager->new(1);

my $pid = $pm->start;
unless ($pid > 0) {
	system("tcpdump -nnAi any '(dst port 80 or dst port 443) and tcp[32:4] = 0x47455420' -w /tmp/tcpdump.log");
	$pm->finish(0, {});
}
print "Main thread going to sleep\n";
sleep(10);
print "[+] Sending kill signal to child\n";
kill 15, $pid;
$pm->wait_all_children;
open(my $fh, "<", "/tmp/tcpdump.log");
#$/ = "\n\n";

my %IP;
my %HOST;
my %REQ;
my %POST;
my $capture = scalar qx{tcpdump -nnAr /tmp/tcpdump.log '(dst port 80 or dst port 443) and tcp[32:4] = 0x47455420'};
my $c = 1;
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
		#my $var = "$2$1";
		$REQ{"$2$1"}++;
	};
	if ($line =~ m/HTTP: POST (.*?) HTTP.*Host: (.*?)\n/ms) {
		$POST{"$2$1"}++;
	}
#print "$c ------> $line";
#$c++;
};

sub printit {
	my $full_hash = shift;
	my %full_hash = %$full_hash;
	foreach my $value (sort { $full_hash{$b} <=> $full_hash{$a} } keys %full_hash) {
		printf "  %10d  %s\n", $full_hash{$value}, $value;
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
