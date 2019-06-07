#!bin/perl
use Statistics::Descriptive;
open (IN, "log2_transform_list"); 
### list of data that need to be log transformed ####
### some data are already in log normal distribution therefore log2 transform no longer needed #####
while (<IN>) {
	chop;
	$logtran{$_}=1;
}
open (IN, $ARGV[0]); ### input dataset list ####
while (<IN>) {
	chop;
	$id=$_;
	print STDERR "processing $id\......\n";
	my %hash=();
	my %transhash=();
	my %hash2=();
	my %transhash2=();
	open (IN1, "$id\_processed.txt");
	$header=<IN1>;
	chop $header;
	@headers=split("\t",$header);
	while (<IN1>) {
		chop;
		@a=split("\t",$_);
		if (exists $logtran{$id}) {
			for my $i (1..$#a) {
				$hash{$a[0]}{$headers[$i]}=log($a[$i]+1)/log(2);
				$transhash{$headers[$i]}{$a[0]}=log($a[$i]+1)/log(2);
			}
		}
		else {
			for my $i (1..$#a) {
				$hash{$a[0]}{$headers[$i]}=$a[$i];
				$transhash{$headers[$i]}{$a[0]}=$a[$i];
			}
		}
	}
	for my $key (keys %transhash) {
		@tmp=();
		for my $key2 (keys %{$transhash{$key}}) {
			push @tmp, $transhash{$key}{$key2};
		}
		my $stat=Statistics::Descriptive::Full->new();
		$stat->add_data(@tmp);
		$mean=$stat->mean();
		$sd=$stat->standard_deviation();
		for my $key2 (keys %{$transhash{$key}}) {
			$transform=($hash{$key2}{$key}-$mean)/$sd;
			$hash2{$key2}{$key}=$transform;
			$transhash2{$key}{$key2}=$transform;
		}
	}
	open (OUT, ">$id\_normalized.txt");
	print OUT "SampleID";
	for my $key (sort keys %transhash2) {
		print OUT "\t$key";
	}
	print OUT "\n";
	for my $key (sort keys %hash2) {
		print OUT $key;
		for my $key2 (sort keys %transhash2) {
			print OUT "\t$hash2{$key}{$key2}";
		}
		print OUT "\n";
	}
}
