#!bin/perl
## This script is used to process microarray data directly downloaded from NCBI GEO database ###
## including a metadata file, a probeset gene match file and a raw expression matrix file ##
## The output is a "$id_processed.txt" for each individual dataset ##

use lib "/home/wangzhang/perl5/lib/perl5/";
use Statistics::Descriptive;

open (IN, "matchlist"); ##### tab delimited matchlist for dataset and platform #######
while (<IN>) {
	chop;
	@a=split("\t",$_);
	$match{$a[0]}=$a[1];
}
for my $id (sort keys %match) {
	my @headers=();
	my %hash=();
	my %transhash=();
	my @a=();
	my %meta=();
	print STDERR "processing $id\.......\n";
	open (IN, "$id\_metadata.txt"); ######## open metadata file ##############
	$dump=<IN>;
	while (<IN>) {
		chop;
		@a=split("\t",$_);
		$meta{$a[0]}=$a[1];
	}
	my %probe2gene=();
	my %gene2probe=();
	open (IN, "mapping/$match{$id}\_mapping.txt"); ########## open probeset match file #############
	while (<IN>) {
		chop;
		@a=split("\t",$_);
		next if ($a[1] eq '');
		#if ($a[1] =~ /\/\/\//) {
		#	@b=split(/ \/\/\/ /, $a[1]);
		#	for my $val (@b) {
		#		$map{$a[0]}{$val}=1;
		#		$transmap{$val}{$a[0]}=1;
		#	}
		#}
		next if (/\/\/\//); 
		$gene2probe{$a[1]}{$a[0]}=1;
		$probe2gene{$a[0]}=$a[1];
	}
	my %genelist=();
	#my %blank=();
	my %iqr=();
	open (IN, "$id\_series_matrix.txt"); ########### open raw matrix file ###############
	while (<IN>) {
		chop;
		s/"//g;
		next if (/^!/);
		if (/^ID_REF/)  {
			@headers=split("\t",$_);
		}
		else {
			@a=split("\t",$_);
			next if (! exists $probe2gene{$a[0]});
			my @c=();
			for my $i (1..$#a) {
				$hash{$a[0]}{$headers[$i]}=$a[$i];
				$transhash{$headers[$i]}{$a[0]}=$a[$i];
				if ($a[$i] ne '') {
					push @c,$a[$i];
				}
			}
			$probeid=$a[0];
			my $stat=Statistics::Descriptive::Full->new();
			$stat->add_data(@c);
			$q3=$stat->quantile(3);
			$q1=$stat->quantile(1);
			$iqr=$q3-$q1;
			$iqr{$probeid}=$iqr;
			#print STDERR $probeid."\t".$iqr."\n";
			$genelist{$probe2gene{$probeid}}=1;
		}
	}
	open (OUT, ">$id\_processed.txt");
	print OUT "SampleID";
	for my $key (sort keys %meta) {
		print OUT "\t$key";
	}
	print OUT "\n";
	for my $key (sort keys %genelist) {
		print OUT $key;
		@tmp=keys %{$gene2probe{$key}};
		for my $val (sort {$iqr{$b}<=>$iqr{$a}} @tmp) {
			next if (! exists $iqr{$val});
			$select=$val;
			last;
		}
		for my $key2 (sort keys %meta) {
			print OUT "\t$hash{$select}{$key2}";
		}
		print OUT "\n";	
	}
}
