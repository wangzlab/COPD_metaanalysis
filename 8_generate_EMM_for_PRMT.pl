#!bin/perl
## This is a script to generate normalized Environmental Metabolomic Matrix (EMM) for PRMT calculation ##
## based on the enzyme-compound association table as input ###
## The output is an enzyme-compound matrix in which the relative contribution score of the enzyme to the compound was indicated ##

open (IN, "microbial_metabolic_reactions.txt"); 
my %contrib=();
#### metabolic reactions with info as: EC\tLeftcmpds\tRightcmpds\tReactiondirection\n as adapted from MetaCyc database ######
while (<IN>) {
	chop;
	@a=split("\t",$_);
	@left=split(";",$a[1]);
	@right=split(";",$a[2]);
	if ($a[3]=~ /LEFT-TO-RIGHT/) {
		for my $val (@left) {
			$contrib{$a[0]}{$val}--;
			$revcon{$val}{$a[0]}--;
		}
		for my $val2 (@right) {
			$contrib{$a[0]}{$val2}++;
			$revcon{$val2}{$a[0]}++;
		}
	}
	elsif ($a[3]=~ /RIGHT-TO-LEFT/) {
		for my $val (@left) {
			$contrib{$a[0]}{$val}++;
			$revcon{$val}{$a[0]}++;
		}
		for my $val2 (@right) {
			$contrib{$a[0]}{$val2}--;
			$revcon{$val2}{$a[0]}--;
		}
	}
	elsif ($a[3] eq '') {
		for my $val (@left) {
			$contrib{$a[0]}{$val}--;
			$revcon{$val}{$a[0]}--;
		}
		for my $val2 (@right) {
			$contrib{$a[0]}{$val2}++;
			$revcon{$val2}{$a[0]}++;
		}
	}
}
print "CMPD";
for my $key (sort keys %contrib) {
	print "\t$key";
}
print "\n";

for my $key (sort keys %revcon) {
	for my $key2 (sort keys %contrib) {
		if (! exists $revcon{$key}{$key2}) {
			$revcon{$key}{$key2}=0;
		}
	}	
}

for my $key (sort keys %revcon) {
	my $pos=0;
	my $neg=0;
	for my $key2 (sort keys %{$revcon{$key}}) {
		if ($revcon{$key}{$key2} > 0) {
			$pos += $revcon{$key}{$key2};
		}
		elsif ($revcon{$key}{$key2} < 0) {
			$neg+=abs($revcon{$key}{$key2});
		}
	}
	for my $key2 (sort keys %{$revcon{$key}}) {
		if ($revcon{$key}{$key2} > 0) {
			$normrev{$key}{$key2}=$revcon{$key}{$key2}/$pos;
		}
		elsif($revcon{$key}{$key2}<0) {
			$normrev{$key}{$key2}=$revcon{$key}{$key2}/$neg;
		}
		else {
			$normrev{$key}{$key2}=0;
		}
	}
}
for my $key (sort keys %normrev) {
	print $key;
	for my $key2 (sort keys %{$normrev{$key}}) {
		print "\t$normrev{$key}{$key2}";
	}
	print "\n";
}
