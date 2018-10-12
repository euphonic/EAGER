use strict;
use warnings;
use Data::Dumper;

my $lookup = "/Users/sarora/dev/EAGER/data/orgs/companies.csv";
open (my $fh, $lookup) or die "Could not open file $lookup: $!"; 
my @lines = <$fh>;
chomp @lines;
close $fh; 

my $fileref = $ARGV[0];

# print Dumper (\@lines);
my $count = 0;

while (<>) {
	my $co = $_;
	chomp $co;
	$co =~ s,\n|\r,,sg;

	my $res = grep ($co =~ m/^$_/, @lines);
	# print "$co: $res\n";

	$count = $res + $count;
}

print "$fileref matches $count records in $lookup\n";